defmodule AkrasiaWeb.WeighingDiagram do
  use AkrasiaWeb, :live_view
  alias Akrasia.Accounts

  def mount(_params, session, socket) do
    user = Accounts.get_user_by_session_token(session["user_token"])
    weighings = Accounts.get_personal_weighings(user.id)
    comparators = Accounts.get_comparators(user.id)

    data = Enum.map(weighings, fn weighing ->
      %{x: Date.to_string(weighing.date), y: Decimal.to_float(weighing.weight)}
    end)

    series = [%{ name: user.email, data: data }]
    |> Jason.encode!()
    |> raw

    {:ok, assign(socket, series: series,
      comparators: comparators,
      comparator_id: 0,
      comparator_name: "Select any from below")}
  end

  def handle_event("compare", %{"comparator-id" => comparator_id}, socket) do
    comparator = Accounts.get_user!(comparator_id)
    comparator_weighings = Accounts.get_personal_weighings(comparator_id)
    comparator_data = Enum.map(comparator_weighings, fn weighing ->
      %{x: Date.to_string(weighing.date), y: Decimal.to_float(weighing.weight)}
    end)

    {:safe, data} = socket.assigns.series
    data = data
    |> Jason.decode!()
    |> List.first()

    series = [data, %{name: comparator.email, data: comparator_data}]
    |> Jason.encode!()
    |> raw

    {:noreply, assign(socket,
      series: series,
      comparator_id: comparator_id,
      comparator_name: comparator.email)}
  end
end
