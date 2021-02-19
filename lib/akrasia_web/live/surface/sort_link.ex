defmodule AkrasiaWeb.Surface.SortLink do
  use Surface.Component
  use AkrasiaWeb.Icons

  prop icon_asc, :string, default: raw(@icon_asc)
  prop icon_desc, :string, default: raw(@icon_desc)
  prop sort_order, :atom
  prop sort_by, :atom
  prop disabled, :boolean
  prop sort_icon, :string

  slot default, required: true

  def mount(_params, _session, socket) do
    socket = socket
     |> assign(sort_icon: sort_icon(socket.assigns.sort_order))
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
