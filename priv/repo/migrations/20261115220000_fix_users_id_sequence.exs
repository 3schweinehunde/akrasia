defmodule Akrasia.Repo.Migrations.FixUsersIdSequence do
  use Ecto.Migration

  # #61: users_id_seq was behind max(users.id) (4 vs. 9 on prod), most likely
  # since the 2021 import of users with explicit ids, so new sign-ups failed
  # with a users_pkey constraint error. Set the sequence to the highest id;
  # on an empty table the next id stays 1.
  def up do
    execute """
    SELECT setval('users_id_seq', COALESCE((SELECT MAX(id) FROM users), 0) + 1, false)
    """
  end

  def down, do: :ok
end
