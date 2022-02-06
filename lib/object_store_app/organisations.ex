defmodule ObjectStoreApp.Organisations do
  alias ObjectStoreApp.Organisations.Organisation
  alias ObjectStoreApp.Store.Minio
  alias ObjectStoreApp.Users

  alias Ecto.Multi

  @default_name "default"

  def create(name, default \\ false, repo \\ ObjectStoreApp.Repo) do
    attrs =
      name
      |> get_aws_secrets(default)
      |> Map.put(:name, name)
      |> Map.put(:is_default, default)

    with {:ok,
          %{
            access_key: access_key,
            secret_key: secret_key
          } = org} <-
           %Organisation{}
           |> Organisation.changeset(attrs)
           |> repo.insert(),
         {:ok, _} <- create_keypair(access_key, secret_key, default) do
      {:ok, org}
    else
      e ->
        e
    end
  end

  def default(repo \\ ObjectStoreApp.Repo) do
    case repo.get_by(Organisation, is_default: true) do
      nil ->
        @default_name
        |> create(true, repo)
        |> elem(1)

      org ->
        org
    end
  end

  def get(name, repo \\ ObjectStoreApp.Repo) do
    case repo.get_by(Organisation, name: name) do
      nil -> {:error, :organisation_not_found}
      %Organisation{} = organisation -> {:ok, repo.preload(organisation, :app_users)}
    end
  end

  def get_or_create(name, repo \\ ObjectStoreApp.Repo) do
    case get(name, repo) do
      {:error, :organisation_not_found} -> create(name, false, repo)
      {:ok, org} -> {:ok, org}
    end
  end

  def delete(name, repo \\ ObjectStoreApp.Repo) do
    case Multi.new()
         |> Multi.run(:get_org, fn repo, _ ->
           get(name, repo)
         end)
         |> Multi.run(:delete_attached_users, fn repo, %{get_org: org} ->
           org.app_users
           |> Enum.reduce(Multi.new(), fn user, multi ->
             Users.delete_multi(multi, user.username)
           end)
           |> repo.transaction()
         end)
         |> Multi.run(:delete_keypair, fn _, %{get_org: org} ->
           delete_keypair(org.access_key, org.is_default)
         end)
         |> Multi.delete(:delete_org, fn %{get_org: org} ->
           org
         end)
         |> repo.transaction() do
      {:ok, _} -> {:ok, nil}
      {:error, :get_org, :organisation_not_found, _} -> {:ok, nil}
      e -> e
    end
  end

  def get_aws_secrets(_, true) do
    %{
      access_key: Application.fetch_env!(:ex_aws, :access_key_id),
      secret_key: Application.fetch_env!(:ex_aws, :secret_access_key)
    }
  end

  def get_aws_secrets(name, false) do
    # create aws keypair

    access_key = "#{name}=#{base64_bytes(16)}"
    secret_access_key = base64_bytes(48)

    %{
      access_key: access_key,
      secret_key: secret_access_key
    }

    # # return global keypair for now
    # get_aws_secrets(@default_name)
  end

  defp create_keypair(_, _, true) do
    # we used the admin key
    {:ok, nil}
  end

  defp create_keypair(access, secret, false) do
    Minio.create_user(access, secret)
  end

  defp delete_keypair(_, true) do
    # we used the admin key
    {:ok, nil}
  end

  defp delete_keypair(access, false) do
    Minio.delete_user(access)
  end

  def base64_bytes(amount) do
    amount
    |> :crypto.strong_rand_bytes()
    |> Base.url_encode64(padding: false)
  end
end
