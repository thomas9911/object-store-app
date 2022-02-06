defmodule ObjectStoreApp.Organisations.Organisation do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "organisations" do
    field :name, :string
    field :is_default, :boolean
    field :access_key, :string
    field :secret_key, :string, redact: true
    has_many :app_users, ObjectStoreApp.Users.User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(organisation, attrs) do
    organisation
    |> cast(attrs, [:name, :is_default, :access_key, :secret_key])
    |> validate_required([:name])
    |> unique_constraint(:default_unique, name: :organisations_is_default_index)

    # |> validate_required([:access_key, :secret_key])
  end

  def create(name, default \\ false, repo \\ ObjectStoreApp.Repo) do
    attrs =
      get_aws_secrets()
      |> Map.put(:name, name)
      |> Map.put(:is_default, default)

    %__MODULE__{}
    |> changeset(attrs)
    |> repo.insert()
  end

  def default(repo \\ ObjectStoreApp.Repo) do
    case repo.get_by(__MODULE__, is_default: true) do
      nil ->
        "default"
        |> create(true, repo)
        |> elem(1)

      org ->
        org
    end
  end

  def get(name, repo \\ ObjectStoreApp.Repo) do
    case repo.get_by(__MODULE__, name: name) do
      nil -> {:error, :organisation_not_found}
      %__MODULE__{} = organisation -> {:ok, repo.preload(organisation, :app_users)}
    end
  end

  def get_aws_secrets do
    %{
      access_key_id: Application.fetch_env!(:ex_aws, :access_key_id),
      secret_access_key: Application.fetch_env!(:ex_aws, :secret_access_key)
    }
  end
end
