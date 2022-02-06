# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :object_store_app,
  ecto_repos: [ObjectStoreApp.Repo],
  generators: [binary_id: true]

config :ex_aws,
  # access_key_id: "nRxhyuGuk3DJPSl7JRTPKd5i75lgCGhpLgFpDW97mK2wMqXc2DntN+ArbLekTCpX",
  # secret_access_key: "WFk0kE7wTcPa0stgx6aHnNABaSpEkl4amhD9tUesnJKkoiPdBPCNBqdAaDol0BAV"
  access_key_id: "access_key",
  secret_access_key: "secret_key"

config :ex_aws, :s3,
  scheme: "http://",
  host: "localhost",
  port: 9000

config :object_store_app, :minio,
  scheme: "http://",
  host: "localhost",
  port: 9001,
  api_version: "v1"

# Configures the endpoint
config :object_store_app, ObjectStoreAppWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [view: ObjectStoreAppWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: ObjectStoreApp.PubSub,
  live_view: [signing_salt: "ox2xMgz+"]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :object_store_app, ObjectStoreApp.Mailer, adapter: Swoosh.Adapters.Local

# Swoosh API client is needed for adapters other than SMTP.
config :swoosh, :api_client, false

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.14.0",
  default: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :comeonin, Ecto.Password, Argon2

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
