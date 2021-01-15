defmodule Akrasia.Accounts.Weighting do
  use Ecto.Schema
  import Ecto.Changeset

  schema "weightings" do
    field :abdominal_girth, :integer
    field :adipose, :decimal
    field :date, :naive_datetime
    field :weight, :decimal
    field :user_id, :id

    timestamps()
  end

  @doc false
  def changeset(weighting, attrs) do
    weighting
    |> cast(attrs, [:date, :weight, :abdominal_girth, :adipose])
    |> validate_required([:date, :weight, :abdominal_girth, :adipose])
  end
end
