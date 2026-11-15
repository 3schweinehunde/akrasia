defmodule Akrasia.RateLimit do
  @moduledoc """
  Rate limiting with Hammer (ETS backend, fixed window), #33.

  Limits the requests that make akrasia send an email (sign-up, magic link)
  per client IP, so bots can't use akrasia to mail strangers' addresses.
  Started in the supervision tree (config :akrasia, :children).

  The limit is configurable (`config :akrasia, Akrasia.RateLimit,
  mail_limit: n`) so the test suite can register many users; default 5 per
  10 minutes.
  """
  use Hammer, backend: :ets

  @mail_window :timer.minutes(10)
  @default_mail_limit 5

  @doc """
  Counts one email-sending request for the given client IP.

  Returns `:ok` while the IP is below the limit, `:error` afterwards.
  """
  def mail_request(ip) when is_binary(ip) do
    case hit("mail:" <> ip, @mail_window, mail_limit()) do
      {:allow, _count} -> :ok
      {:deny, _retry_after} -> :error
    end
  end

  defp mail_limit do
    :akrasia
    |> Application.get_env(__MODULE__, [])
    |> Keyword.get(:mail_limit, @default_mail_limit)
  end
end
