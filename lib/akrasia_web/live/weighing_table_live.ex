defmodule AkrasiaWeb.WeighingTableLive do
  use AkrasiaWeb, :live_view

  def mount(_params, _session, socket) do
    socket = assign(socket,
               id: "",
               date: "",
               weight: "",
               abdominal_girth: "",
               adipose: "",
               user_id: "",
               weighings: [],)
    {:ok, socket}
  end

  def handle_params(params, _url, socket) do
    page = String.to_integer(params["page"] || "1")
    per_page = String.to_integer(params["per_page"] || "10")

    sort_by = (params["sort_by"] || "id") |> String.to_atom()
    sort_order = (params["sort_order"] || "asc") |> String.to_atom()

    paginate_options = %{page: page, per_page: per_page}
    sort_options = %{sort_by: sort_by, sort_order: sort_order}

    weighings =
      Akrasia.Accounts.list_weighings(
        paginate: paginate_options,
        sort: sort_options
      )

    socket =
      assign(socket,
        options: Map.merge(paginate_options, sort_options),
        weighings: weighings
      )

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

  def handle_event("id-search", %{"value" => id }, socket) do
    search_options = %{search_by: :id, search_term: id}
    socket = assign(socket,
               options: Map.merge(socket.assigns.options, search_options),
               id: id)

    socket = get_weighings(socket, search_options)
    {:noreply, socket}
  end

  def handle_event("weight-search", %{"value" => weight }, socket) do
    search_options = %{search_by: :weight, search_term: weight}
    socket = assign(socket,
               options: Map.merge(socket.assigns.options, search_options),
               weight: weight)

    socket = get_weighings(socket, search_options)
    {:noreply, socket}
  end

  defp get_weighings(socket, search_options) do
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
        search: search_options
      )

    assign(socket, weighings: weighings)
  end
end
