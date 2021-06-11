defmodule Akrasia.MixProject do
  use Mix.Project

  def project do
    [
      app: :akrasia,
      version: "0.1.0",
      elixir: "~> 1.7",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Akrasia.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      # algorithm used for comeonin
      {:bcrypt_elixir, "~> 2.0"},
      # web framework
      {:phoenix, "~> 1.5.7"},
      # phoenix support for ecto
      {:phoenix_ecto, "~> 4.1"},
      # ecto sql adapter
      {:ecto_sql, "~> 3.4"},
      # database adapter
      {:postgrex, ">= 0.0.0"},
      # database adapter
      {:myxql, "~> 0.4.0"},
      # phoenix live views
      {:phoenix_live_view, "~> 0.15.0"},
      # HTML parser
      {:floki, ">= 0.27.0", only: :test},
      # view layer
      {:phoenix_html, "~> 2.11"},
      # live reloading in development
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      # live view dashboard
      {:phoenix_live_dashboard, "~> 0.4"},
      # defines metrics based on telemetry events
      {:telemetry_metrics, "~> 0.4"},
      # collect and dispatching measurements as telemetry events
      {:telemetry_poller, "~> 0.4"},
      # i18n and l10n
      {:gettext, "~> 0.11"},
      # Json generation,
      {:jason, "~> 1.0"},
      # web server plug
      {:plug_cowboy, "~> 2.0"},
      # athlentication code generator
      {:phx_gen_auth, "~> 0.6", only: [:dev], runtime: false},
      # mailing smtp adapter,
      {:bamboo_smtp, "~> 3.0"},
      # mailing
      {:bamboo, "~> 1.4"},
      # frontend component framework
      {:surface, "~> 0.1.0"},
      # Creating a pidfile
      {:pid_file, "~> 0.1.1"},
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to install project dependencies and perform other setup tasks, run:
  #
  #     $ mix setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      setup: ["deps.get", "ecto.setup", "cmd npm install --prefix assets"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"]
    ]
  end
end
