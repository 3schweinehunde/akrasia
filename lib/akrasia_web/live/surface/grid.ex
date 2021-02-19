defmodule AkrasiaWeb.Surface.Grid do
  use Surface.Component
  use AkrasiaWeb.Icons

  prop options, :list
  prop records_getter_params, :map,
  prop search_options, :map, %{}
  prop like_search, :boolean, default: false
  data records, :list, default: []

  def mount(_params, _session, socket) do
    socket = socket
     |> get_records()
     |> Surface.init()
    {:ok, socket}
  end

  defp toggle_sort_order(:asc), do: :desc
  defp toggle_sort_order(:desc), do: :asc

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

  defp column_search(form, column_name, value) do
    text_input(form, String.to_atom(column_name),
      value: value,
      placeholder: column_name,
      autofocus: "autofocus",
      autocomplete: "off",
      class: "w-20 p-1.5",
      phx_debounce: 300)
  end
end
