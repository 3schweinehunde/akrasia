defmodule AkrasiaWeb.Surface.SortLink do
  use Surface.Component
  use AkrasiaWeb.Icons

  prop sort_order, :atom
  prop sort_by, :atom
  prop disabled, :boolean

  slot default, required: true

  def mount(_params, _session, socket) do
    socket = socket
     |> assign(socket, sort_icon: sort_icon(socket.assigns.sort_order))
     |> Surface.init()
    {:ok, socket}
  end

  defp sort_icon(sort_order) do
    case sort_order do
      :asc  -> @icon_asc
      :desc -> @icon_desc
      _     -> ""
    end
  end

  defp toggle_sort_order(:asc), do: :desc
  defp toggle_sort_order(:desc), do: :asc
end
