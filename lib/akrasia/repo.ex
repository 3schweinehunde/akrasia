defmodule Akrasia.Repo do
  use Ecto.Repo,
    otp_app: :akrasia,
    adapter: Ecto.Adapters.Postgres
end
