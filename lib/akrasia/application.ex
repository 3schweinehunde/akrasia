defmodule Akrasia.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      Akrasia.Repo,
#      Akrasia.LegacyRepo,
      # Start the Telemetry supervisor
      AkrasiaWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Akrasia.PubSub},
      # Start the Endpoint (http/https)
      AkrasiaWeb.Endpoint
      # Start a worker by calling: Akrasia.Worker.start_link(arg)
      # {Akrasia.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Akrasia.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    AkrasiaWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
