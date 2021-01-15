defmodule Akrasia.Accounts.Weighing do
  use Ecto.Schema
  import Ecto.Changeset

  schema "weighings" do
    field :abdominal_girth, :integer
    field :adipose, :decimal
    field :date, :naive_datetime
    field :weight, :decimal
    belongs_to :user, Akrasia.Accounts.User, foreign_key: :user_id

    timestamps()
  end

  @doc false
  def changeset(weighing, attrs) do
    weighing
    |> cast(attrs, [:date, :weight, :abdominal_girth, :adipose, :user_id])
    |> validate_required([:date, :weight, :abdominal_girth, :adipose])
  end
end
