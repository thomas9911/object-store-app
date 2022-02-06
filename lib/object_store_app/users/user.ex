defmodule ObjectStoreApp.Users.User do
  use Ecto.Schema
  import Ecto.Changeset

  alias ObjectStoreApp.Organisations.Organisation

  @primary_key {:id, Ecto.UUID, autogenerate: true}
  @foreign_key_type Ecto.UUID
  schema "app_users" do
    field :username, :string
    field :password, Comeonin.Ecto.Password
    belongs_to :organisation, Organisation

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:username, :password, :organisation_id])
    |> validate_required([:username, :password])
  end
end
