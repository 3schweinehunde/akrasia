defmodule AkrasiaWeb.ClientIP do
  @moduledoc """
  The client's IP address in a LiveView, for rate limiting (#33).

  In prod akrasia runs behind nginx, so the peer address is nginx itself.
  The real client comes from `X-Real-IP`, or the last entry of
  `X-Forwarded-For` (the one nginx appended; earlier entries can be forged
  by the client). Without these headers (dev, test, or nginx not setting
  them) the peer address is used, and in prod all clients then share one
  limit.

  Needs `connect_info: [:peer_data, :x_headers, ...]` on the LiveView socket
  in the endpoint. Only available while mounting.
  """
  import Phoenix.LiveView, only: [get_connect_info: 2, connected?: 1]

  @doc """
  Returns the client IP as a string, or `"unknown"` when the socket is not
  connected yet.
  """
  def from_socket(socket) do
    if connected?(socket) do
      from_headers(get_connect_info(socket, :x_headers) || []) ||
        from_peer(get_connect_info(socket, :peer_data))
    else
      "unknown"
    end
  end

  @doc false
  def from_headers(headers) do
    real_ip = List.keyfind(headers, "x-real-ip", 0)
    forwarded_for = List.keyfind(headers, "x-forwarded-for", 0)

    cond do
      real_ip ->
        real_ip |> elem(1) |> String.trim()

      forwarded_for ->
        forwarded_for |> elem(1) |> String.split(",") |> List.last() |> String.trim()

      true ->
        nil
    end
  end

  defp from_peer(%{address: address}), do: address |> :inet.ntoa() |> to_string()
  defp from_peer(_), do: "unknown"
end
