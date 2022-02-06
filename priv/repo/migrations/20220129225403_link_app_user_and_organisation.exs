defmodule ObjectStoreApp.Repo.Migrations.LinkUserAndOrganisation do
  use Ecto.Migration

  def change do
    alter table(:app_users) do
      add :organisation_id, references(:organisations, type: :binary_id, on_delete: :delete_all)
    end
  end
end
