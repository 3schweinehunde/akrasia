defmodule AkrasiaWeb.Grid do
  use AkrasiaWeb, :live_component
  use AkrasiaWeb.Icons

  def mount(socket) do
    socket =
      assign(socket,
        records: [],
        options: %{},
        records_getter_params: %{},
        search_options: %{},
        like_search: false,
        icon_show: raw(@icon_show),
        icon_edit: raw(@icon_edit),
        icon_delete: raw(@icon_delete)
      )

    {:ok, socket}
  end

  def update(assigns, socket) do
    socket = assign(socket, assigns)
    socket = get_records(socket)
    {:ok, socket}
  end

  defp pagination_link(socket, opts) do
    [
      options: options,
      caller: caller,
      link_title: link_title,
      page: page,
      class: class,
      myself: myself,
      path_helper: path_helper
    ] = opts

    if opts[:caller] do
      live_patch(link_title,
        to:
          Function.capture(Routes, path_helper, 3).(socket, caller,
            page: page,
            per_page: options.per_page,
            sort_by: options.sort_by,
            sort_order: options.sort_order
          ),
        class: class
      )
    else
      link(link_title,
        to: "#",
        phx_click: "paginate",
        phx_target: myself,
        phx_value_page: page,
        phx_value_per_page: options.per_page,
        class: class
      )
    end
  end

  defp sort_link(socket, opts) do
    [
      link_title: link_title,
      sort_by: sort_by,
      options: options,
      caller: caller,
      myself: myself,
      path_helper: path_helper
    ] = opts

    link_title =
      if sort_by == options.sort_by do
        if options.sort_order == :asc do
          raw(@icon_asc <> " " <> link_title)
        else
          raw(@icon_desc <> " " <> link_title)
        end
      else
        link_title
      end

    if caller do
      live_patch(link_title,
        to:
          Function.capture(Routes, path_helper, 3).(socket, caller,
            sort_by: sort_by,
            sort_order: toggle_sort_order(options.sort_order),
            page: options.page,
            per_page: options.per_page
          )
      )
    else
      link(link_title,
        to: "#",
        phx_click: "sort",
        phx_target: myself,
        phx_value_sort_by: sort_by,
        phx_value_sort_order: toggle_sort_order(options.sort_order)
      )
    end
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

  def handle_event("sort", %{"sort-by" => sort_by, "sort-order" => sort_order}, socket) do
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
          per_page: socket.assigns.options.per_page
        },
        sort: %{
          sort_by: socket.assigns.options.sort_by,
          sort_order: socket.assigns.options.sort_order
        },
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
      phx_debounce: 300
    )
  end
end
