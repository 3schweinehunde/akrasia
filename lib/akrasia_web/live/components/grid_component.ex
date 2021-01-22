defmodule AkrasiaWeb.GridComponent do
  use AkrasiaWeb, :live_component

  def mount(socket) do
    socket = assign(socket,
               records: [],
               options: %{},
               search_options: %{},
               like_search: false)
    {:ok, socket}
  end

  def update(assigns, socket) do
    socket = assign(socket, assigns)
    socket = get_records(socket)
    {:ok, socket}
  end

  defp pagination_link(socket, opts) do
    [options: options,
     caller: caller,
     link_title: link_title,
     page: page,
     class: class] = opts

    live_patch(link_title,
      to:
        Routes.live_path(socket, caller,
          page: page,
          per_page: options.per_page,
          sort_by: options.sort_by,
          sort_order: options.sort_order
        ),
      class: class
    )
  end

  defp sort_link(socket, opts) do
    [link_title: link_title,
     sort_by: sort_by,
     options: options,
     caller: caller] = opts

    link_title =
      if sort_by == options.sort_by do
         icon(options.sort_order) <> " " <> link_title
      else
        link_title
      end

    live_patch(raw(link_title),
      to:
        Routes.live_path(socket, caller,
          sort_by: sort_by,
          sort_order: toggle_sort_order(options.sort_order),
          page: options.page,
          per_page: options.per_page
        )
    )
  end

  defp toggle_sort_order(:asc), do: :desc
  defp toggle_sort_order(:desc), do: :asc

  defp icon(:asc) do """
      <svg xmlns="http://www.w3.org/2000/svg"
          class="w-8 h-8 inline-block"
          viewBox="0 0 32 32">
        <path d="M 4 5 L 4 7 L 6 7 L 6 5 Z M 21 5 L 21 23.6875 L 18.40625 21.09375 L 17 22.5 L 21.28125 26.8125 L 22 27.5 L 22.71875 26.8125 L 27 22.5 L 25.59375 21.09375 L 23 23.6875 L 23 5 Z M 4 9 L 4 11 L 8 11 L 8 9 Z M 4 13 L 4 15 L 10 15 L 10 13 Z M 4 17 L 4 19 L 12 19 L 12 17 Z M 4 21 L 4 23 L 14 23 L 14 21 Z M 4 25 L 4 27 L 16 27 L 16 25 Z"/>
      </svg>
     """
  end
  defp icon(:desc) do """
      <svg xmlns="http://www.w3.org/2000/svg"
           class="w-8 h-8 inline-block"
           viewBox="0 0 32 32">
        <path d="M 4 5 L 4 7 L 16 7 L 16 5 Z M 21 5 L 21 23.6875 L 18.40625 21.09375 L 17 22.5 L 21.28125 26.8125 L 22 27.5 L 22.71875 26.8125 L 27 22.5 L 25.59375 21.09375 L 23 23.6875 L 23 5 Z M 4 9 L 4 11 L 14 11 L 14 9 Z M 4 13 L 4 15 L 12 15 L 12 13 Z M 4 17 L 4 19 L 10 19 L 10 17 Z M 4 21 L 4 23 L 8 23 L 8 21 Z M 4 25 L 4 27 L 6 27 L 6 25 Z"/>
      </svg>
    """
  end
  defp icon(:show) do """
      <svg xmlns="http://www.w3.org/2000/svg"
           class="w-6 h-6 inline-block fill-current"
           viewBox="0 0 32 32">
        <path d="M 16 8 C 7.664063 8 1.25 15.34375 1.25 15.34375 L 0.65625 16 L 1.25 16.65625 C 1.25 16.65625 7.097656 23.324219 14.875 23.9375 C 15.246094 23.984375 15.617188 24 16 24 C 16.382813 24 16.753906 23.984375 17.125 23.9375 C 24.902344 23.324219 30.75 16.65625 30.75 16.65625 L 31.34375 16 L 30.75 15.34375 C 30.75 15.34375 24.335938 8 16 8 Z M 16 10 C 18.203125 10 20.234375 10.601563 22 11.40625 C 22.636719 12.460938 23 13.675781 23 15 C 23 18.613281 20.289063 21.582031 16.78125 21.96875 C 16.761719 21.972656 16.738281 21.964844 16.71875 21.96875 C 16.480469 21.980469 16.242188 22 16 22 C 15.734375 22 15.476563 21.984375 15.21875 21.96875 C 11.710938 21.582031 9 18.613281 9 15 C 9 13.695313 9.351563 12.480469 9.96875 11.4375 L 9.9375 11.4375 C 11.71875 10.617188 13.773438 10 16 10 Z M 16 12 C 14.34375 12 13 13.34375 13 15 C 13 16.65625 14.34375 18 16 18 C 17.65625 18 19 16.65625 19 15 C 19 13.34375 17.65625 12 16 12 Z M 7.25 12.9375 C 7.09375 13.609375 7 14.285156 7 15 C 7 16.753906 7.5 18.394531 8.375 19.78125 C 5.855469 18.324219 4.105469 16.585938 3.53125 16 C 4.011719 15.507813 5.351563 14.203125 7.25 12.9375 Z M 24.75 12.9375 C 26.648438 14.203125 27.988281 15.507813 28.46875 16 C 27.894531 16.585938 26.144531 18.324219 23.625 19.78125 C 24.5 18.394531 25 16.753906 25 15 C 25 14.285156 24.90625 13.601563 24.75 12.9375 Z"/>
      </svg>
    """
  end
  defp icon(:edit) do """
      <svg xmlns="http://www.w3.org/2000/svg"
           class="w-6 h-6 inline-block fill-current"
           viewBox="0 0 32 32">
        <path d="M 25 4.03125 C 24.234375 4.03125 23.484375 4.328125 22.90625 4.90625 L 13 14.78125 L 12.78125 15 L 12.71875 15.3125 L 12.03125 18.8125 L 11.71875 20.28125 L 13.1875 19.96875 L 16.6875 19.28125 L 17 19.21875 L 17.21875 19 L 27.09375 9.09375 C 28.246094 7.941406 28.246094 6.058594 27.09375 4.90625 C 26.515625 4.328125 25.765625 4.03125 25 4.03125 Z M 25 5.96875 C 25.234375 5.96875 25.464844 6.089844 25.6875 6.3125 C 26.132813 6.757813 26.132813 7.242188 25.6875 7.6875 L 16 17.375 L 14.28125 17.71875 L 14.625 16 L 24.3125 6.3125 C 24.535156 6.089844 24.765625 5.96875 25 5.96875 Z M 4 8 L 4 28 L 24 28 L 24 14.8125 L 22 16.8125 L 22 26 L 6 26 L 6 10 L 15.1875 10 L 17.1875 8 Z"/>
      </svg>
    """
  end
  defp icon(:delete) do """
      <svg xmlns="http://www.w3.org/2000/svg"
           class="w-6 h-6 inline-block fill-current"
           viewBox="0 0 32 32">
        <path d="M 14 4 C 13.476563 4 12.941406 4.183594 12.5625 4.5625 C 12.183594 4.941406 12 5.476563 12 6 L 12 7 L 5 7 L 5 9 L 6.09375 9 L 8 27.09375 L 8.09375 28 L 23.90625 28 L 24 27.09375 L 25.90625 9 L 27 9 L 27 7 L 20 7 L 20 6 C 20 5.476563 19.816406 4.941406 19.4375 4.5625 C 19.058594 4.183594 18.523438 4 18 4 Z M 14 6 L 18 6 L 18 7 L 14 7 Z M 8.125 9 L 23.875 9 L 22.09375 26 L 9.90625 26 Z M 12 12 L 12 23 L 14 23 L 14 12 Z M 15 12 L 15 23 L 17 23 L 17 12 Z M 18 12 L 18 23 L 20 23 L 20 12 Z"/>
      </svg>
    """
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

  def handle_event("toggle_search_mode", _, socket) do
    socket = assign(socket, like_search: !socket.assigns.like_search)
    socket = get_records(socket)

    {:noreply, socket}
  end

  defp get_records(socket) do
    paginate_options =
      %{page: socket.assigns.options.page,
        per_page: socket.assigns.options.per_page
      }
    sort_options =
      %{sort_by: socket.assigns.options.sort_by,
        sort_order: socket.assigns.options.sort_order
      }

    records =
      socket.assigns.config.function_retrieving_records.(
        paginate: paginate_options,
        sort: sort_options,
        search: socket.assigns.search_options,
        like_search: socket.assigns.like_search
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
