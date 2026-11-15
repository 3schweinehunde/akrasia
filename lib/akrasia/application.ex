defmodule Akrasia.Application do
  # See https://elixir.hexdocs.pm/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    # The children are configured per environment (config/dev.exs, test.exs,
    # prod.exs), like in pan; prod adds the pid file worker.
    children = Application.fetch_env!(:akrasia, :children)

    # See https://elixir.hexdocs.pm/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Akrasia.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    AkrasiaWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
