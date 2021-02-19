defmodule AkrasiaWeb.Surface.Grid do
  use Surface.Component
  alias AkrasiaWeb.Surface.{SortLink, Pagination}
  alias Surface.Components.{Form, Link}
  alias Surface.Components.Form.TextInput
  alias AkrasiaWeb.Router.Helpers, as: Routes
  use AkrasiaWeb.Icons

  prop icon_show, :string, default: raw(@icon_show)
  prop icon_edit, :string, default: raw(@icon_edit)
  prop icon_delete, :string, default: raw(@icon_delete)

  prop id, :string, required: true
  prop heading, :string, default: "Records"
  prop current_page, :integer, default: 1
  prop per_page, :integer, default: 10
  prop sort_by, :atom, default: :id
  prop sort_order, :atom, default: :asc
  prop path_helper, :atom, required: true
  prop records_getter, :module, required: true
  prop records_getter_params, :map, default: %{}
  prop search_options, :map, default: %{}
  prop like_search, :boolean, default: false
  prop columns, :list, required: true
  data records, :list, default: []

  def update(assigns, socket) do
    socket = socket
    |> assign(assigns)
    |> get_records()
    {:ok, socket}
  end

  def handle_event("search", %{"search" => search}, socket) do
    [column_string | _] = Map.keys(search)
    column = String.to_atom(column_string)
    search_options = Map.merge(socket.assigns.search_options, %{column => search[column_string]})
    socket = assign(socket, search_options: search_options)
    socket = assign(socket, %{column => search[column_string]})
    socket = get_records(socket)

    {:noreply, socket}
  end

  def handle_event("sort", %{"sort-by"=> sort_by, "sort-order"=> sort_order}, socket) do
    socket = socket
      |> assign(sort_by: String.to_atom(sort_by), sort_order: String.to_atom(sort_order))
      |> get_records()
    {:noreply, socket}
  end

  def handle_event("paginate", %{"page" => page, "per-page" => per_page}, socket) do
    socket = socket
      |> assign(current_page: String.to_integer(page), per_page: String.to_integer(per_page))
      |> get_records()
    {:noreply, socket}
  end

  def handle_event("toggle_search_mode", _, socket) do
    socket = socket
      |> assign(like_search: !socket.assigns.like_search)
      |> get_records()
    {:noreply, socket}
  end

  defp get_records(socket) do
    records =
      socket.assigns.records_getter.(
        paginate: %{
          page: socket.assigns.current_page,
          per_page: socket.assigns.per_page},
        sort: %{
          sort_by: socket.assigns.sort_by,
          sort_order: socket.assigns.sort_order },
        search: socket.assigns.search_options,
        like_search: socket.assigns.like_search,
        additional_params: socket.assigns[:records_getter_params]
      )

    assign(socket, records: records)
  end
end
