defmodule ObjectStoreApp.Repo.Migrations.CreateAppUser do
  use Ecto.Migration

  def change do
    create table(:app_users, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :username, :string
      add :password, :string

      timestamps(type: :timestamptz)
    end

    create unique_index(:app_users, [:username])
  end
end
