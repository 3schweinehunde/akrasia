defmodule Akrasia.Legacy.User do
  use Ecto.Schema
  import Ecto.Changeset

  @field_source_mapper fn
    :inserted_at -> :created_at
    x -> x
  end

  schema "users" do
    field :admin, :boolean, default: false
    field :email, :string
    field :hashed_password, :string
    field :height, :integer
    field :invitation_id, :integer
    field :invitation_limit, :integer
    field :public, :boolean, default: false
    field :salt, :string
    field :target, :decimal

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :id, :height, :public, :invitation_id, :invitation_limit, :target,
                    :admin, :hashed_password, :salt])
    |> validate_required([:email, :height, :public, :invitation_id, :invitation_limit, :target,
                          :admin, :hashed_password, :salt])
  end
end
