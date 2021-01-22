defmodule AkrasiaWeb.WeighingTableLive do
  use AkrasiaWeb, :live_view
  alias AkrasiaWeb.GridComponent

  def mount(_params, _session, socket) do
    socket = assign(socket, options: %{})
    {:ok, socket}
  end

  def handle_params(params, _url, socket) do
    page = String.to_integer(params["page"] || "1")
    per_page = String.to_integer(params["per_page"] || "10")

    sort_by = (params["sort_by"] || "id") |> String.to_atom()
    sort_order = (params["sort_order"] || "asc") |> String.to_atom()

    paginate_options = %{page: page, per_page: per_page}
    sort_options = %{sort_by: sort_by, sort_order: sort_order}

    socket = assign(socket, options: Map.merge(paginate_options, sort_options))
    {:noreply, socket}
  end
end
