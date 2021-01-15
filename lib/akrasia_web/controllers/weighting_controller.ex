defmodule AkrasiaWeb.WeightingController do
  use AkrasiaWeb, :controller

  alias Akrasia.Accounts
  alias Akrasia.Accounts.Weighting

  def index(conn, _params) do
    weightings = Accounts.list_weightings()
    render(conn, "index.html", weightings: weightings)
  end

  def new(conn, _params) do
    changeset = Accounts.change_weighting(%Weighting{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"weighting" => weighting_params}) do
    case Accounts.create_weighting(weighting_params) do
      {:ok, weighting} ->
        conn
        |> put_flash(:info, "Weighting created successfully.")
        |> redirect(to: Routes.weighting_path(conn, :show, weighting))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    weighting = Accounts.get_weighting!(id)
    render(conn, "show.html", weighting: weighting)
  end

  def edit(conn, %{"id" => id}) do
    weighting = Accounts.get_weighting!(id)
    changeset = Accounts.change_weighting(weighting)
    render(conn, "edit.html", weighting: weighting, changeset: changeset)
  end

  def update(conn, %{"id" => id, "weighting" => weighting_params}) do
    weighting = Accounts.get_weighting!(id)

    case Accounts.update_weighting(weighting, weighting_params) do
      {:ok, weighting} ->
        conn
        |> put_flash(:info, "Weighting updated successfully.")
        |> redirect(to: Routes.weighting_path(conn, :show, weighting))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", weighting: weighting, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    weighting = Accounts.get_weighting!(id)
    {:ok, _weighting} = Accounts.delete_weighting(weighting)

    conn
    |> put_flash(:info, "Weighting deleted successfully.")
    |> redirect(to: Routes.weighting_path(conn, :index))
  end
end
