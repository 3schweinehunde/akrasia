defmodule AkrasiaWeb.WeighingTableLive do
  use AkrasiaWeb, :live_view

  def mount(_params, _session, socket) do
    columns = [
      %{field: :id,
        name: "ID",
        sortable: true,
        searchable: true},
      %{field: :date,
        name: "Date",
        sortable: true,
        searchable: true},
      %{field: :weight,
        name: "Weight",
        sortable: true,
        searchable: true},
      %{field: :abdominal_girth,
        name: "Abdominal girth",
        sortable: true,
        searchable: true},
      %{field: :adipose,
        name: "adipose",
        sortable: true,
        searchable: true},
      %{field: :user_id,
        name: "User Id",
        sortable: true,
        searchable: true},
      %{field: :user_name,
        name: "User Name",
        template_function: &Akrasia.Accounts.Weighing.user_email/1 }
    ]

    socket = assign(socket,
               columns: columns,
               weighings: [],
               options: %{},
               search_options: %{},
               like_search: false)
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
    socket = get_weighings(socket)

    {:noreply, socket}
  end

  defp pagination_link(socket, text, page, options, class) do
    live_patch(text,
      to:
        Routes.live_path(socket, __MODULE__,
          page: page,
          per_page: options.per_page,
          sort_by: options.sort_by,
          sort_order: options.sort_order
        ),
      class: class
    )
  end

  defp sort_link(socket, text, sort_by, options) do
    text =
      if sort_by == options.sort_by do
        text <> " " <> emoji(options.sort_order)
      else
        text
      end

    live_patch(text,
      to:
        Routes.live_path(
          socket,
          __MODULE__,
          sort_by: sort_by,
          sort_order: toggle_sort_order(options.sort_order),
          page: options.page,
          per_page: options.per_page
        )
    )
  end

  defp toggle_sort_order(:asc), do: :desc
  defp toggle_sort_order(:desc), do: :asc

  defp emoji(:asc), do: "⬆️"
  defp emoji(:desc), do: "⬇️"

  def handle_event("search", %{"search" => search}, socket) do
    [column_string | _] = Map.keys(search)
    column = String.to_atom(column_string)
    search_options = Map.merge(socket.assigns.search_options, %{column => search[column_string]})
    socket = assign(socket, search_options: search_options)
    socket = assign(socket, %{column => search[column_string]})
    socket = get_weighings(socket)

    {:noreply, socket}
  end

  def handle_event("toggle_search_mode", _, socket) do
    socket = assign(socket, like_search: !socket.assigns.like_search)
    socket = get_weighings(socket)

    {:noreply, socket}
  end

  defp get_weighings(socket) do
    paginate_options =
      %{page: socket.assigns.options.page,
        per_page: socket.assigns.options.per_page
      }
    sort_options =
      %{sort_by: socket.assigns.options.sort_by,
        sort_order: socket.assigns.options.sort_order
      }

    weighings =
      Akrasia.Accounts.list_weighings(
        paginate: paginate_options,
        sort: sort_options,
        search: socket.assigns.search_options,
        like_search: socket.assigns.like_search
      )

    assign(socket, weighings: weighings)
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
