defmodule AkrasiaWeb.WeighingDiagram do
  use AkrasiaWeb, :live_view
  alias Akrasia.Accounts

  def mount(_params, session, socket) do
    user = Accounts.get_user_by_session_token(session["user_token"])
    weighings = Accounts.get_personal_weighings(user.id)

    data = Enum.map(weighings, fn weighing ->
      %{x: Date.to_string(weighing.date), y: Decimal.to_float(weighing.weight)}
    end)
    |> Jason.encode!()
    |> raw

    {:ok, assign(socket, data: data)}
  end
end
