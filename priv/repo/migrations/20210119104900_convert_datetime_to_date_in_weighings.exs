defmodule Akrasia.Repo.Migrations.CreateWeighings do
  use Ecto.Migration

  def change do
    alter table(:weighings) do
      modify :date, :date
    end
  end
end
