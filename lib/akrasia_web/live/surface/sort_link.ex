defmodule AkrasiaWeb.Surface.SortLink do
  use Surface.Component
  prop sort_order, :atom
  prop sort_by, :atom
  prop target, :module
  prop disabled, :boolean

  slot default, required: true

  def mount(_params, _session, socket) do
    socket = socket
     |> assign(socket, sort_icon: sort_icon(@sort_order))
     |> Surface.init()
    {:ok, socket}
  end

  defp sort_icon(sort_order) do
    case sort_order do
      :asc  => @icon_asc
      :desc => @icon_desc
      _     => ""
    end
  end
end
