defmodule Akrasia.Legacy.Weighing do
  use Ecto.Schema
  import Ecto.Changeset

  schema "weighings" do
    field :date, :date
    field :user_id, :integer
    field :weight, :decimal

    timestamps()
  end

  @doc false
  def changeset(weighing, attrs) do
    weighing
    |> cast(attrs, [:date, :weight, :user_id])
    |> validate_required([:date, :weight, :user_id])
  end
end
