defmodule Akrasia.LegacyRepo do
  use Ecto.Repo,
    otp_app: :akrasia,
    adapter: Ecto.Adapters.MyXQL
end
