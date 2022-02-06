defmodule ObjectStoreApp.Repo.Migrations.CreateOrganisations do
  use Ecto.Migration

  def change do
    create table(:organisations, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string
      add :access_key, :string
      add :secret_key, :string
      add :is_default, :boolean

      timestamps(type: :timestamptz)
    end

    create unique_index(:organisations, [:name])
    create unique_index(:organisations, [:is_default], where: "is_default is true")
  end
end
