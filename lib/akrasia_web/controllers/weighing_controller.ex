defmodule AkrasiaWeb.WeighingController do
  use AkrasiaWeb, :controller

  alias Akrasia.Accounts
  alias Akrasia.Accounts.Weighing

  def new(conn, _params) do
    changeset = Accounts.change_weighing(%Weighing{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"weighing" => weighing_params}) do
    case Accounts.create_weighing(weighing_params) do
      {:ok, weighing} ->
        conn
        |> put_flash(:info, "Weighing created successfully.")
        |> redirect(to: Routes.weighing_path(conn, :show, weighing))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    weighing = Accounts.get_weighing!(id)
    render(conn, "show.html", weighing: weighing)
  end

  def edit(conn, %{"id" => id}) do
    weighing = Accounts.get_weighing!(id)
    changeset = Accounts.change_weighing(weighing)
    render(conn, "edit.html", weighing: weighing, changeset: changeset)
  end

  def update(conn, %{"id" => id, "weighing" => weighing_params}) do
    weighing = Accounts.get_weighing!(id)

    case Accounts.update_weighing(weighing, weighing_params) do
      {:ok, weighing} ->
        conn
        |> put_flash(:info, "Weighing updated successfully.")
        |> redirect(to: Routes.weighing_path(conn, :show, weighing))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", weighing: weighing, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    weighing = Accounts.get_weighing!(id)
    {:ok, _weighing} = Accounts.delete_weighing(weighing)

    conn
    |> put_flash(:info, "Weighing deleted successfully.")
    |> redirect(to: Routes.weighing_path(conn, :index))
  end
end
