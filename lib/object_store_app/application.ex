defmodule ObjectStoreApp.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      ObjectStoreApp.Repo,
      # Start the Telemetry supervisor
      ObjectStoreAppWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: ObjectStoreApp.PubSub},
      # Start the Endpoint (http/https)
      ObjectStoreAppWeb.Endpoint
      # Start a worker by calling: ObjectStoreApp.Worker.start_link(arg)
      # {ObjectStoreApp.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ObjectStoreApp.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    ObjectStoreAppWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
