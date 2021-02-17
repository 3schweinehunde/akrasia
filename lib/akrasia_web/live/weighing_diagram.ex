defmodule AkrasiaWeb.WeighingDiagram do
  use AkrasiaWeb, :live_view
  alias Akrasia.Accounts
  alias Akrasia.Accounts.Weighing
  use Phoenix.HTML
  import Ecto.Query, warn: false

  def mount(_params, session, socket) do
    user = Accounts.get_user_by_session_token(session["user_token"])
    weighings = Accounts.get_personal_weighings(user.id)
    comparators = Accounts.get_comparators(user.id)
    weighing_changeset = Accounts.change_weighing(%Weighing{weight: List.last(weighings).weight, user_id: user.id})

    data = Enum.map(weighings, fn weighing ->
      %{x: Date.to_string(weighing.date),
        y: round(1000000 * Decimal.to_float(weighing.weight) /
           Decimal.to_float(user.height) /
           Decimal.to_float(user.height))/100
      }
    end)

    series = [%{ name: user.name, data: data }]
    |> Jason.encode!()
    |> raw

    {:ok, assign(socket, series: series,
      comparators: comparators,
      comparator_id: 0,
      comparator_name: "Select below",
      last_weighing: List.last(weighings),
      weighing_changeset: weighing_changeset
    )}
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

    series = [data, %{name: comparator.name, data: comparator_data}]

    socket = assign(socket, comparator_id: comparator_id, comparator_name: comparator.name)
    {:noreply, push_event(socket, "series", %{series: series})}
  end

  def handle_event("validate_weighing", %{"weighing" => params}, socket) do
    changeset =
      %Weighing{}
      |> Accounts.change_weighing(params)
      |> Map.put(:action, :insert)

    {:noreply, assign(socket, changeset: changeset)}
  end
end
