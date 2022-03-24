defmodule AkrasiaWeb.WeighingDiagram do
  use AkrasiaWeb, :live_view
  alias Akrasia.Accounts
  alias Akrasia.Accounts.Weighing
  use Phoenix.HTML
  import Ecto.Query, warn: false
  import AkrasiaWeb.ErrorHelpers

  def mount(_params, session, socket) do
    user = Accounts.get_user_by_session_token(session["user_token"])
    weighings = Accounts.get_personal_weighings(user.id)
    comparators = Accounts.get_comparators(user.id)

    user_bmi_data =
      Enum.map(weighings, fn weighing ->
        %{
          x: Date.to_string(weighing.date),
          y:
            round(
              1_000_000 * Decimal.to_float(weighing.weight) /
                Decimal.to_float(user.height) /
                Decimal.to_float(user.height)
            ) / 100
        }
      end)

    weighing_changeset =
      Accounts.change_weighing(%Weighing{
        date: Date.utc_today(),
        weight: List.last(weighings).weight
      })

    {:ok,
     assign(socket,
       user_data: to_json(user_bmi_data),
       comparators: comparators,
       comparator_id: 0,
       comparator_name: "Select below",
       comparator_series: [],
       last_weighing: List.last(weighings),
       weighing_changeset: weighing_changeset,
       user_id: user.id,
       user_name: user.name
     )}
  end

  def handle_event("compare", %{"comparator-id" => comparator_id}, socket) do
    comparator = Accounts.get_user!(comparator_id)
    comparator_weighings = Accounts.get_personal_weighings(comparator_id)

    comparator_bmi_data =
      Enum.map(comparator_weighings, fn weighing ->
        %{
          x: Date.to_string(weighing.date),
          y:
            round(
              1_000_000 * Decimal.to_float(weighing.weight) /
                Decimal.to_float(comparator.height) /
                Decimal.to_float(comparator.height)
            ) / 100
        }
      end)

    comparator_series = %{name: comparator.name, data: comparator_bmi_data}

    socket =
      assign(socket,
        comparator_id: comparator_id,
        comparator_name: comparator.name
      )

    {:noreply, push_event(socket, "comparatorSeries", %{data: comparator_series})}
  end

  def handle_event("validate_weighing", %{"weighing" => params}, socket) do
    changeset =
      %Weighing{}
      |> Accounts.change_weighing(params)
      |> Map.put(:action, :insert)

    {:noreply, assign(socket, weighing_changeset: changeset)}
  end

  def handle_event("create_weighing", %{"weighing" => weighing_params}, socket) do
    weighing_params = Map.put(weighing_params, "user_id", socket.assigns.user_id)

    case Accounts.create_weighing(weighing_params) do
      {:ok, weighing} ->
        assign(socket, weighing_changeset: Accounts.change_weighing(%Weighing{}))

        user = Accounts.get_user!(socket.assigns.user_id)
        weighings = Accounts.get_personal_weighings(weighing.user_id)

        user_bmi_data =
          Enum.map(weighings, fn weighing ->
            %{
              x: Date.to_string(weighing.date),
              y:
                round(
                  1_000_000 * Decimal.to_float(weighing.weight) /
                    Decimal.to_float(user.height) /
                    Decimal.to_float(user.height)
                ) / 100
            }
          end)

        user_series = %{name: socket.assigns.user_name, data: user_bmi_data}
        socket = push_event(socket, "userSeries", %{data: user_series})
        {:noreply, put_flash(socket, :info, "Wägung gespeichert")}

      {:error, %Ecto.Changeset{} = weighing_changeset} ->
        {:noreply, assign(socket, weighing_changeset: weighing_changeset)}
    end
  end

  def to_json(struct) do
    struct
    |> Jason.encode!()
    |> raw
  end
end
