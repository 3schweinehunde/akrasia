defmodule Akrasia.MixProject do
  use Mix.Project

  def project do
    [
      app: :akrasia,
      version: "0.1.0",
      elixir: "~> 1.18",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      compilers: [:phoenix_live_view] ++ Mix.compilers(),
      listeners: [Phoenix.CodeReloader]
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

  def cli do
    [
      preferred_envs: [precommit: :test]
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
      # web framework
      {:phoenix, "~> 1.8.16"},
      # phoenix support for ecto
      {:phoenix_ecto, "~> 4.7"},
      # ecto sql adapter
      {:ecto_sql, "~> 3.14"},
      # database adapter
      {:postgrex, "~> 0.22"},
      # reactive view layer
      {:phoenix_live_view, "~> 1.2.0"},
      # HTML helpers
      {:phoenix_html, "~> 4.1"},
      # live metrics dashboard
      {:phoenix_live_dashboard, "~> 0.9.1"},
      # admin panel (#46)
      {:backpex, "~> 0.24.1"},
      # web server
      {:bandit, "~> 1.5"},
      # algorithm used by phx.gen.auth
      {:bcrypt_elixir, "~> 3.3"},
      # rate limiting for sign-up and magic-link requests (#33)
      {:hammer, "~> 7.5"},
      # mailing
      {:swoosh, "~> 1.29"},
      {:gen_smtp, "~> 1.3"},
      # defines metrics based on telemetry events
      {:telemetry_metrics, "~> 1.0"},
      # collect and dispatch measurements as telemetry events
      {:telemetry_poller, "~> 1.0"},
      # i18n and l10n
      {:gettext, "~> 1.0"},
      # JSON generation
      {:jason, "~> 1.2"},
      # creating a pidfile
      {:pid_file, "~> 0.2.0"},

      # Mix task invoking esbuild
      {:esbuild, "~> 0.10", runtime: Mix.env() == :dev},
      # CSS framework
      {:tailwind, "~> 0.5", runtime: Mix.env() == :dev},
      # icons (vendored by the Phoenix generator)
      {:heroicons,
       github: "tailwindlabs/heroicons",
       tag: "v2.2.0",
       sparse: "optimized",
       app: false,
       compile: false,
       depth: 1},
      # DaisyUI (vendored by the Phoenix generator)
      {:daisyui,
       github: "saadeghi/daisyui",
       tag: "v5.5.20",
       sparse: "packages/bundle",
       app: false,
       compile: false,
       depth: 1},
      # live browser page reload on code changes
      {:phoenix_live_reload, "~> 1.2", only: :dev},

      # MCP server giving Claude access to the running app
      {:tidewave, "~> 0.9.2", only: :dev},
      # usage rules synced into CLAUDE.md
      {:usage_rules, "~> 1.3", only: :dev},
      # codegen/installer framework, required by the claude package's installer
      {:igniter, "~> 0.8.5", only: [:dev, :test]},
      # Claude Code project integration (hooks, MCP servers, usage rules)
      {:claude, "~> 0.5.3", only: [:dev, :test]},
      # code analysis
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      # security-focused static analysis (mix sobelow)
      {:sobelow, "~> 0.19.0", only: [:dev, :test], runtime: false},
      # DOM parser required by Phoenix.LiveViewTest
      {:lazy_html, ">= 0.1.0", only: :test}
    ]
  end

  defp aliases do
    [
      setup: [
        "deps.get",
        "ecto.setup",
        "cmd npm install --prefix assets",
        "assets.setup",
        "assets.build"
      ],
      "ecto.setup": ["ecto.create", "ecto.migrate"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"],
      "assets.setup": ["tailwind.install --if-missing", "esbuild.install --if-missing"],
      "assets.build": ["compile", "tailwind akrasia", "esbuild akrasia"],
      "assets.deploy": [
        "tailwind akrasia --minify",
        "esbuild akrasia --minify",
        "phx.digest"
      ],
      precommit: ["compile --warnings-as-errors", "deps.unlock --unused", "format", "test"]
    ]
  end
end
