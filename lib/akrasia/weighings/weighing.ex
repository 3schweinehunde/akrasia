defmodule Akrasia.Weighings.Weighing do
  @moduledoc """
  One weighing of a user: date and weight (kg), optionally abdominal girth
  (cm) and body fat (adipose, %).

  `user_id` is never cast from user input; `Akrasia.Weighings` sets it from
  the caller's scope.
  """
  use Ecto.Schema
  import Ecto.Changeset

  schema "weighings" do
    field :date, :date
    field :weight, :decimal
    field :abdominal_girth, :integer
    field :adipose, :decimal

    belongs_to :user, Akrasia.Accounts.User

    timestamps()
  end

  @doc false
  def changeset(weighing, attrs) do
    weighing
    |> cast(attrs, [:date, :weight, :abdominal_girth, :adipose])
    |> validate_required([:date, :weight])
    |> validate_number(:weight, greater_than: 0, less_than: 500)
    |> validate_number(:abdominal_girth, greater_than: 0, less_than: 500)
    |> validate_number(:adipose, greater_than_or_equal_to: 0, less_than: 100)
  end
end
