defmodule Akrasia.Weighings do
  @moduledoc """
  The Weighings context (#38): a user's weighings, their BMI series for the
  diagram, and the public users to compare with.

  Every function that reads or changes weighings takes the caller's
  `Akrasia.Accounts.Scope`, so "my weighings" is enforced here and not by
  each caller. Admins work on weighings through Backpex (#46).
  """
  import Ecto.Query, warn: false

  alias Akrasia.Accounts.Scope
  alias Akrasia.Accounts.User
  alias Akrasia.Repo
  alias Akrasia.Weighings.Weighing

  @sortable_fields ~w(date weight abdominal_girth adipose)a

  @doc "The fields the weighings list can be sorted by (#4: a fixed list)."
  def sortable_fields, do: @sortable_fields

  @doc """
  Lists the scope user's weighings.

  ## Options

    * `:sort_by` - one of `sortable_fields/0`, default `:date`
    * `:sort_order` - `:asc` or `:desc`, default `:desc`
    * `:page` and `:per_page` - default 1 and 20
  """
  def list_weighings(%Scope{} = scope, opts \\ []) do
    sort_by = Keyword.get(opts, :sort_by, :date)
    sort_order = Keyword.get(opts, :sort_order, :desc)
    page = Keyword.get(opts, :page, 1)
    per_page = Keyword.get(opts, :per_page, 20)

    unless sort_by in @sortable_fields and sort_order in [:asc, :desc] do
      raise ArgumentError, "can't sort weighings by #{inspect({sort_by, sort_order})}"
    end

    from(w in Weighing,
      where: w.user_id == ^scope.user.id,
      order_by: [{^sort_order, field(w, ^sort_by)}, {^sort_order, w.id}],
      limit: ^per_page,
      offset: ^((page - 1) * per_page)
    )
    |> Repo.all()
  end

  @doc "Counts the scope user's weighings."
  def count_weighings(%Scope{} = scope) do
    Repo.aggregate(from(w in Weighing, where: w.user_id == ^scope.user.id), :count)
  end

  @doc "The scope user's most recent weighing (by date), or nil."
  def last_weighing(%Scope{} = scope) do
    from(w in Weighing,
      where: w.user_id == ^scope.user.id,
      order_by: [desc: w.date, desc: w.id],
      limit: 1
    )
    |> Repo.one()
  end

  @doc """
  Gets one of the scope user's weighings. Raises `Ecto.NoResultsError` for
  weighings of other users.
  """
  def get_weighing!(%Scope{} = scope, id) do
    Repo.get_by!(Weighing, id: id, user_id: scope.user.id)
  end

  @doc "Creates a weighing for the scope user."
  def create_weighing(%Scope{} = scope, attrs) do
    %Weighing{user_id: scope.user.id}
    |> Weighing.changeset(attrs)
    |> Repo.insert()
  end

  @doc "Updates one of the scope user's weighings."
  def update_weighing(%Scope{} = scope, %Weighing{} = weighing, attrs) do
    true = weighing.user_id == scope.user.id

    weighing
    |> Weighing.changeset(attrs)
    |> Repo.update()
  end

  @doc "Deletes one of the scope user's weighings."
  def delete_weighing(%Scope{} = scope, %Weighing{} = weighing) do
    true = weighing.user_id == scope.user.id
    Repo.delete(weighing)
  end

  @doc "Returns a changeset for the weighing forms."
  def change_weighing(%Scope{} = scope, %Weighing{} = weighing, attrs \\ %{}) do
    true = weighing.user_id in [nil, scope.user.id]
    Weighing.changeset(weighing, attrs)
  end

  ## BMI

  @doc """
  The body mass index for a weight in kg and a height in cm, rounded to two
  decimals, or nil without a height (#3: the only BMI calculation).
  """
  def bmi(_weight, nil), do: nil

  def bmi(%Decimal{} = weight, %Decimal{} = height_cm) do
    height_m = Decimal.div(height_cm, 100)

    weight
    |> Decimal.div(Decimal.mult(height_m, height_m))
    |> Decimal.round(2)
    |> Decimal.to_float()
  end

  @doc """
  The user's BMI over time for the diagram: `[[iso_date, bmi], ...]` ordered
  by date; empty without a height.
  """
  def bmi_series(%User{height: nil}), do: []

  def bmi_series(%User{} = user) do
    from(w in Weighing,
      where: w.user_id == ^user.id,
      order_by: [asc: w.date, asc: w.id],
      select: {w.date, w.weight}
    )
    |> Repo.all()
    |> Enum.map(fn {date, weight} -> [Date.to_iso8601(date), bmi(weight, user.height)] end)
  end

  @doc "The BMI of the user's target weight, or nil."
  def target_bmi(%User{target: nil}), do: nil
  def target_bmi(%User{} = user), do: bmi(user.target, user.height)

  ## Comparators

  @doc """
  The users the scope user can compare with: public, with a height, not the
  user themselves; ordered by name.
  """
  def list_comparators(%Scope{} = scope) do
    comparators_query(scope)
    |> order_by([u], asc: u.name, asc: u.id)
    |> Repo.all()
  end

  @doc """
  Gets a comparator by id, or nil for users that are not comparators (not
  public, no height, oneself) and for ids that are no integers. The old
  diagram loaded any user id the browser sent.
  """
  def get_comparator(%Scope{} = scope, id) do
    case Integer.parse(to_string(id)) do
      {id, ""} -> scope |> comparators_query() |> where([u], u.id == ^id) |> Repo.one()
      _ -> nil
    end
  end

  defp comparators_query(%Scope{} = scope) do
    from(u in User,
      where: u.id != ^scope.user.id and u.public == true and not is_nil(u.height)
    )
  end
end
