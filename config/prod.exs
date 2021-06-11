use Mix.Config

config :akrasia, AkrasiaWeb.Endpoint,
  http: [port: 9999, compress: false],
  url: [scheme: "https", host: "akrasia.informatom.com", port: 443],
  cache_static_manifest: "priv/static/cache_manifest.json"
  root: ".",
  check_origin: ["https://akrasia.informatom.com"],
  version: Mix.Project.config()[:version]

config :logger, level: :info

config :akrasia, :environment, "production"
config :phoenix, :serve_endpoints, true

import_config "prod.secret.exs"
