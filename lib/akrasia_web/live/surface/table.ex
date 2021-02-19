defmodule AkrasiaWeb.Surface.Table do
  use Surface.LiveComponent

  prop data, :list, required: true

  @doc "The CSS class for the wrapping `<div>` element"
  prop class, :css_class

  @doc """
  A function that returns a class for the item's underlying `<tr>`
  element. The function receives the item and index related to
  the row.
  """
  prop row_class, :fun

  slot cols, props: [item: ^data], required: true

  data sorted_data, :list, default: nil
  data sorted_by, :any, default: nil
  data sort_reverse, :boolean, default: false

  def update(assigns, socket) do
    socket = assign(socket, assigns)
    socket = assign(socket, :sorted_data, sorted_data(socket.assigns))

    {:ok, socket}
  end

  def handle_event(
        "sorted_click",
        %{"value" => sort_by_new},
        socket = %{assigns: %{sorted_by: sorted_by, sort_reverse: sort_reverse}}
      ) do
    socket =
      cond do
        sorted_by != sort_by_new ->
          assign(socket, :sorted_by, sort_by_new)
          |> assign(:sort_reverse, false)

        sorted_by == sort_by_new ->
          assign(socket, :sort_reverse, !sort_reverse)
      end

    socket = assign(socket, :sorted_data, sorted_data(socket.assigns))
    {:noreply, socket}
  end

  defp sorted_data(assigns) do
    cond do
      !is_nil(assigns.sorted_by) ->
        sorted_data =
          case assigns.sorted_by do
            sorter when is_binary(sorter) ->
              # We have to try to fetch both by string and atom key as
              # we don't know if the data is using string or atom keys.
              Enum.sort_by(assigns.data, fn i ->
                Map.get(i, sorter) || Map.get(i, String.to_atom(sorter))
              end)

            sorter when is_function(sorter) ->
              Enum.sort_by(assigns.data, sorter)

            {sorter, comparer} when is_function(sorter) and is_function(comparer) ->
              Enum.sort_by(assigns.data, sorter, comparer)
          end

        sorted_data =
          if assigns.sort_reverse == true do
            Enum.reverse(sorted_data)
          else
            sorted_data
          end

        sorted_data

      is_nil(assigns.sorted_data) ->
        assigns.data

      true ->
        assigns.sorted_data
    end
  end

  defp row_class_fun(nil), do: fn _, _ -> "" end
  defp row_class_fun(row_class), do: row_class
end
