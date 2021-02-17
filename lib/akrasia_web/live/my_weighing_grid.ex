defmodule AkrasiaWeb.MyWeighingGrid do
  use AkrasiaWeb, :live_view
  alias AkrasiaWeb.Grid
  alias Akrasia.Accounts

  def mount(_params, session, socket) do
    user = Accounts.get_user_by_session_token(session["user_token"])
    socket = assign(socket, options: %{}, current_user_id: user.id)
    {:ok, socket}
  end

  def handle_params(params, _url, socket) do
    paginate_options =
      %{page: String.to_integer(params["page"] || "1"),
        per_page: String.to_integer(params["per_page"] || "10")}
    sort_options =
      %{sort_by: (params["sort_by"] || "id") |> String.to_atom(),
        sort_order: (params["sort_order"] || "asc") |> String.to_atom()}

    socket = assign(socket, options: Map.merge(paginate_options, sort_options))
    {:noreply, socket}
  end
end
