defmodule Akrasia.Accounts.Weighing do
  use Ecto.Schema
  import Ecto.Changeset

  schema "weighings" do
    field :abdominal_girth, :integer
    field :adipose, :decimal
    field :date, :date
    field :weight, :decimal
    belongs_to :user, Akrasia.Accounts.User, foreign_key: :user_id

    timestamps()
  end

  @doc false
  def changeset(weighing, attrs) do
    weighing
    |> cast(attrs, [:date, :weight, :abdominal_girth, :adipose, :user_id])
    |> validate_required([:date, :weight])
  end

  def from_legacy_weighing(legacy_weighing) do
    struct(__MODULE__, legacy_weighing)
  end

  def user_email(weighing) do
    weighing.user && weighing.user.email
  end
end
