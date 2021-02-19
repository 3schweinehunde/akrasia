defmodule AkrasiaWeb.Surface.Grid do
  use Surface.Component
  alias AkrasiaWeb.Surface.{SortLink, Pagination}
  alias Surface.Components.{Form, Link}
  alias Surface.Components.Form.TextInput

  prop page, :integer, default: 1
  prop per_page, :integer, default: 10
  prop sort_by, :atom, default: :id
  prop sort_order, :itom, default: :asc
  prop records_getter, :module
  prop records_getter_params, :map, default: %{}
  prop search_options, :map, default: %{}
  prop like_search, :boolean, default: false
  data records, :list, default: []

  def mount(_params, _session, socket) do
    socket = socket
     |> get_records()
     |> Surface.init()
    {:ok, socket}
  end

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
    sort_options = %{sort_by: String.to_atom(sort_by), sort_order: String.to_atom(sort_order)}
    socket = assign(socket, options: Map.merge(socket.assigns.options, sort_options))

    socket = get_records(socket)
    {:noreply, socket}
  end

  def handle_event("paginate", %{"page" => page, "per-page" => per_page}, socket) do
    paginate_options = %{page: String.to_integer(page), per_page: String.to_integer(per_page)}
    socket = assign(socket, options: Map.merge(socket.assigns.options, paginate_options))

    socket = get_records(socket)
    {:noreply, socket}
  end

  def handle_event("toggle_search_mode", _, socket) do
    socket = assign(socket, like_search: !socket.assigns.like_search)
    socket = get_records(socket)

    {:noreply, socket}
  end

  defp get_records(socket) do
    records =
      socket.assigns.config.records_getter.(
        paginate: %{
          page: socket.assigns.options.page,
          per_page: socket.assigns.options.per_page},
        sort: %{
          sort_by: socket.assigns.options.sort_by,
          sort_order: socket.assigns.options.sort_order },
        search: socket.assigns.search_options,
        like_search: socket.assigns.like_search,
        additional_params: socket.assigns.config[:records_getter_params]
      )

    assign(socket, records: records)
  end
end
