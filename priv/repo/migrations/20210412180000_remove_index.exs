defmodule Akrasia.Repo.Migrations.CreateWeighings do
  use Ecto.Migration

  def change do
    drop index(:weighings, [:user_id])
  end
end
