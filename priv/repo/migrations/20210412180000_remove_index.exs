defmodule Akrasia.Repo.Migrations.RemoveIndex do
  use Ecto.Migration

  def change do
    drop index(:weighings, [:user_id])
  end
end
