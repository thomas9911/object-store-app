defmodule ObjectStoreApp.Repo do
  use Ecto.Repo,
    otp_app: :object_store_app,
    adapter: Ecto.Adapters.Postgres
end
