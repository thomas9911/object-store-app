defmodule ObjectStoreApp.Users do
  @moduledoc false

  alias ObjectStoreApp.Users.User

  alias Ecto.Multi

  def create(username, password, org \\ nil, repo \\ ObjectStoreApp.Repo) do
    org =
      if is_nil(org) do
        {:ok, ObjectStoreApp.Organisations.default()}
      else
        ObjectStoreApp.Organisations.get_or_create(org)
      end

    with {:ok, org} <- org,
         changeset <-
           User.changeset(%User{}, %{
             username: username,
             password: password,
             organisation_id: org.id
           }),
         {:ok, user} <- repo.insert(changeset),
         {:ok, _bucket} <- ObjectStoreApp.Store.create_bucket(username) do
      {:ok, user}
    end
  end

  def get(username, repo \\ ObjectStoreApp.Repo) do
    case repo.get_by(User, username: username) do
      nil -> {:error, :user_not_found}
      %User{} = user -> {:ok, repo.preload(user, :organisation)}
    end
  end

  def delete(username, repo \\ ObjectStoreApp.Repo) do
    case Multi.new()
         |> delete_multi(username)
         |> repo.transaction() do
      {:ok, _} -> {:ok, nil}
      {:error, _, :user_not_found, _} -> {:ok, nil}
      e -> e
    end
  end

  def delete_multi(multi, username) do
    username_step = "get_user_#{username}"

    multi
    |> Multi.run(username_step, fn repo, _ ->
      get(username, repo)
    end)
    |> Multi.run("delete_bucket_#{username}", fn _, _ ->
      ObjectStoreApp.Store.delete_bucket(username)
    end)
    |> Multi.delete("delete_user_#{username}", fn %{^username_step => user} ->
      user
    end)
  end

  @doc "same as get but the password also needs to be the same"
  def login(username, password, repo \\ ObjectStoreApp.Repo) do
    case get(username, repo) do
      {:ok, user} ->
        Argon2.check_pass(user, password, hash_key: :password)

      e ->
        Argon2.no_user_verify()
        e
    end
  end
end
