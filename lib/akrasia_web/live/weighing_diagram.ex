defmodule AkrasiaWeb.WeighingDiagram do
  use AkrasiaWeb, :live_view
  alias Akrasia.Accounts

  def mount(_params, session, socket) do
    user = Accounts.get_user_by_session_token(session["user_token"])
    weighings = Accounts.get_personal_weighings(user.id)
    comparators = Accounts.get_comparators(user.id)

    IO.puts(user.height)

    data = Enum.map(weighings, fn weighing ->
      %{x: Date.to_string(weighing.date),
        y: round(1000000 * Decimal.to_float(weighing.weight) /
           Decimal.to_float(user.height) /
           Decimal.to_float(user.height))/100
      }
    end)

    series = [%{ name: user.email, data: data }]
    |> Jason.encode!()
    |> raw

    {:ok, assign(socket, series: series,
      comparators: comparators,
      comparator_id: 0,
      comparator_name: "Select below")}
  end

  def handle_event("compare", %{"comparator-id" => comparator_id}, socket) do
    comparator = Accounts.get_user!(comparator_id)
    comparator_weighings = Accounts.get_personal_weighings(comparator_id)
    comparator_data = Enum.map(comparator_weighings, fn weighing ->
      %{x: Date.to_string(weighing.date),
        y: round(1000000 *  Decimal.to_float(weighing.weight) /
           Decimal.to_float(comparator.height) /
           Decimal.to_float(comparator.height)) / 100
      }
    end)

    {:safe, data} = socket.assigns.series
    data = data
    |> Jason.decode!()
    |> List.first()

    series = [data, %{name: comparator.email, data: comparator_data}]

    socket = assign(socket, comparator_id: comparator_id, comparator_name: comparator.name)
    {:noreply, push_event(socket, "series", %{series: series})}
  end
end
