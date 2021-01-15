defmodule Akrasia.Repo.Migrations.CreateWeightings do
  use Ecto.Migration

  def change do
    create table(:weightings) do
      add :date, :naive_datetime
      add :weight, :decimal
      add :abdominal_girth, :integer
      add :adipose, :decimal
      add :user_id, references(:users, on_delete: :nothing)

      timestamps()
    end

    create index(:weightings, [:user_id])
  end
end
