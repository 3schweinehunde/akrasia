defmodule AkrasiaWeb.PageController do
  use AkrasiaWeb, :controller
  alias Akrasia.Accounts
  alias Akrasia.Accounts.User

  def index(conn, _params) do
    changeset = Accounts.change_user_registration(%User{})
    render(conn, "index.html", error_message: nil, changeset: changeset)
  end

  def show(conn, %{"template" => template}) do
    render(conn, "#{template}.html")
  end
end
