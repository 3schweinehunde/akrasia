defmodule AkrasiaWeb.WeighingDiagram do
  use AkrasiaWeb, :live_view
  alias Akrasia.Accounts

  def mount(_params, session, socket) do
    user = Accounts.get_user_by_session_token(session["user_token"])
    weighings = Accounts.get_personal_weighings(user.id)

    socket = assign(socket, weighings: weighings)
    {:ok, socket}
  end
end
