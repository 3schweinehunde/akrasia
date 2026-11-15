defmodule Akrasia.Repo.Migrations.UpgradeAuthToPhoenix18 do
  use Ecto.Migration

  # The users and users_tokens tables exist since 20210111154506 (phx.gen.auth
  # of Phoenix 1.5). Phoenix 1.8's phx.gen.auth (#25, #29) needs two changes:
  # magic-link users may have no password, and tokens record when the user
  # authenticated (sudo mode).
  def change do
    alter table(:users) do
      modify :hashed_password, :string, null: true, from: {:string, null: false}
    end

    alter table(:users_tokens) do
      add :authenticated_at, :naive_datetime
    end

    # Existing sessions stay valid: they were authenticated when created.
    execute "UPDATE users_tokens SET authenticated_at = inserted_at WHERE context = 'session'",
            ""

    # Reset-password and email-change tokens of the old flows are useless now.
    execute "DELETE FROM users_tokens WHERE context <> 'session'", ""
  end
end
