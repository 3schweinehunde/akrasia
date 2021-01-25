defmodule Akrasia.Repo.Migrations.CreateWeighings do
  use Ecto.Migration

  def change do
    create table(:weighings) do
      add :date, :date
      add :weight, :decimal
      add :abdominal_girth, :integer
      add :adipose, :decimal
      add :user_id, references(:users, on_delete: :nothing)

      timestamps()
    end

    create index(:weighings, [:user_id])
  end
end
