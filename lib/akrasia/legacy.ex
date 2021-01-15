defmodule Akrasia.Legacy do
  @moduledoc """
  The Legacy context.
  """

  import Ecto.Query, warn: false
  alias Akrasia.Repo

  alias Akrasia.Legacy.Weighing

  @doc """
  Returns the list of weighings.

  ## Examples

      iex> list_weighings()
      [%Weighing{}, ...]

  """
  def list_weighings do
    Repo.all(Weighing)
  end

  @doc """
  Gets a single weighing.

  Raises `Ecto.NoResultsError` if the Weighing does not exist.

  ## Examples

      iex> get_weighing!(123)
      %Weighing{}

      iex> get_weighing!(456)
      ** (Ecto.NoResultsError)

  """
  def get_weighing!(id), do: Repo.get!(Weighing, id)

  @doc """
  Creates a weighing.

  ## Examples

      iex> create_weighing(%{field: value})
      {:ok, %Weighing{}}

      iex> create_weighing(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_weighing(attrs \\ %{}) do
    %Weighing{}
    |> Weighing.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a weighing.

  ## Examples

      iex> update_weighing(weighing, %{field: new_value})
      {:ok, %Weighing{}}

      iex> update_weighing(weighing, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_weighing(%Weighing{} = weighing, attrs) do
    weighing
    |> Weighing.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a weighing.

  ## Examples

      iex> delete_weighing(weighing)
      {:ok, %Weighing{}}

      iex> delete_weighing(weighing)
      {:error, %Ecto.Changeset{}}

  """
  def delete_weighing(%Weighing{} = weighing) do
    Repo.delete(weighing)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking weighing changes.

  ## Examples

      iex> change_weighing(weighing)
      %Ecto.Changeset{data: %Weighing{}}

  """
  def change_weighing(%Weighing{} = weighing, attrs \\ %{}) do
    Weighing.changeset(weighing, attrs)
  end
end
