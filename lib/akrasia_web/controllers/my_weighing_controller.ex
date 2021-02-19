defmodule AkrasiaWeb.MyWeighingController do
  use AkrasiaWeb, :controller

  alias Akrasia.Accounts
  alias Akrasia.Accounts.Weighing
  @remember_me_cookie "_akrasia_web_user_remember_me"

  def new(conn, _params) do
    changeset = Accounts.change_weighing(%Weighing{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"weighing" => weighing_params}) do
    case Accounts.create_weighing(weighing_params) do
      {:ok, weighing} ->
        conn
        |> put_flash(:info, "Weighing created successfully.")
        |> redirect(to: Routes.my_weighing_path(conn, :show, weighing))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    weighing = Accounts.get_my_weighing!(id, get_current_user(conn))
    render(conn, "show.html", weighing: weighing)
  end

  def edit(conn, %{"id" => id}) do
    weighing = Accounts.get_my_weighing!(id, get_current_user(conn))
    changeset = Accounts.change_weighing(weighing)
    render(conn, "edit.html", weighing: weighing, changeset: changeset)
  end

  def update(conn, %{"id" => id, "weighing" => weighing_params}) do
    weighing = Accounts.get_my_weighing!(id, get_current_user(conn))

    case Accounts.update_weighing(weighing, weighing_params) do
      {:ok, weighing} ->
        conn
        |> put_flash(:info, "Weighing updated successfully.")
        |> redirect(to: Routes.my_weighing_path(conn, :show, weighing))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", weighing: weighing, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    weighing = Accounts.get_my_weighing!(id, get_current_user(conn))
    {:ok, _weighing} = Accounts.delete_weighing(weighing)

    conn
    |> put_flash(:info, "Weighing deleted successfully.")
    |> redirect(to: Routes.my_weighing_path(conn, :index))
  end

  defp get_current_user(conn) do
    {user_token, _} = ensure_user_token(conn)
    user_token && Accounts.get_user_by_session_token(user_token)
  end

  defp ensure_user_token(conn) do
    if user_token = get_session(conn, :user_token) do
      {user_token, conn}
    else
      conn = fetch_cookies(conn, signed: [@remember_me_cookie])

      if user_token = conn.cookies[@remember_me_cookie] do
        {user_token, put_session(conn, :user_token, user_token)}
      else
        {nil, conn}
      end
    end
  end
end
