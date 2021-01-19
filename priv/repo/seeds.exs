# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Akrasia.Repo.insert!(%Akrasia.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

Akrasia.Repo.delete_all(Akrasia.Accounts.User)
users = Akrasia.LegacyRepo.all(Akrasia.Legacy.User)

for user <- users do
  user
  |> Map.drop([:admin, :height])
  |> Map.from_struct()
  |> Akrasia.Accounts.User.from_legacy_user()
  |> Akrasia.Repo.insert!()
 end

Akrasia.Repo.delete_all(Akrasia.Accounts.Weighing)
weighings = Akrasia.LegacyRepo.all(Akrasia.Legacy.Weighing)

for weighing <- weighings do
  weighing
  |> Map.from_struct()
  |> Akrasia.Accounts.Weighing.from_legacy_weighing()
  |> Akrasia.Repo.preload(:user)
  |> Akrasia.Repo.insert!()
 end
