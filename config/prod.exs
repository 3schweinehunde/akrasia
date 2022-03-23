import Config

config :akrasia, AkrasiaWeb.Endpoint,
  http: [port: 9999, compress: false],
  url: [scheme: "https", host: "akrasia.informatom.com", port: 443],
  cache_static_manifest: "priv/static/cache_manifest.json",
  server: true,
  root: ".",
  check_origin: ["https://akrasia.informatom.com"],
  version: Mix.Project.config()[:version]

config :logger, level: :info

config :akrasia, :environment, "prod"

config :akrasia, :children, [
  Akrasia.Repo,
  AkrasiaWeb.Telemetry,
  {Phoenix.PubSub, name: :akrasia_pubsub, adapter: Phoenix.PubSub.PG2},
  AkrasiaWeb.Endpoint,
  {PidFile.Worker, file: "pan.pid"}
]

import_config "prod.secret.exs"
