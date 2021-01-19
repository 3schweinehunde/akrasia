defmodule Akrasia.Legacy do
  import Ecto.Query, warn: false
  alias Akrasia.Repo
  alias Akrasia.Legacy.Weighing
  alias Akrasia.Legacy.User

  def list_weighings do
    Repo.all(Weighing)
  end

  def get_weighing!(id), do: Repo.get!(Weighing, id)

  def create_weighing(attrs \\ %{}) do
    %Weighing{}
    |> Weighing.changeset(attrs)
    |> Repo.insert()
  end

  def update_weighing(%Weighing{} = weighing, attrs) do
    weighing
    |> Weighing.changeset(attrs)
    |> Repo.update()
  end

  def delete_weighing(%Weighing{} = weighing) do
    Repo.delete(weighing)
  end

  def change_weighing(%Weighing{} = weighing, attrs \\ %{}) do
    Weighing.changeset(weighing, attrs)
  end

  def list_users do
    Repo.all(User)
  end

  def get_user!(id), do: Repo.get!(User, id)

  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  def change_user(%User{} = user, attrs \\ %{}) do
    User.changeset(user, attrs)
  end
end
