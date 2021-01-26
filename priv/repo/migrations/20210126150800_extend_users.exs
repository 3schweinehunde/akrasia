defmodule Akrasia.Repo.Migrations.ExtendUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :admin, :boolean
      add :height, :decimal
      add :public, :boolean
      add :invitation_limit, :integer
      add :target, :decimal
    end
  end
end
