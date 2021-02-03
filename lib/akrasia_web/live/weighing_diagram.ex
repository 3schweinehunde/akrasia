defmodule AkrasiaWeb.WeighingDiagram do
  use AkrasiaWeb, :live_view

  def mount(_params, _session, socket) do
    socket = assign(socket, weighings: [])
    {:ok, socket}
  end

  def update(assigns, socket) do
    socket = assign(socket, assigns)
    socket = get_weighings(socket)
    {:ok, socket}
  end

  defp get_weighings(socket) do
    weighings = Akrasia.Accounts.list_personal_weighings()
    assign(socket, weighings: weighings)
  end
end
