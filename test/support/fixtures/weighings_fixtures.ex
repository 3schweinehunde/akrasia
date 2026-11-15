defmodule Akrasia.WeighingsFixtures do
  @moduledoc """
  Test helpers for creating weighings through `Akrasia.Weighings`.
  """

  alias Akrasia.Accounts
  alias Akrasia.Accounts.Scope
  alias Akrasia.AccountsFixtures

  def weighing_fixture(%Scope{} = scope, attrs \\ %{}) do
    {:ok, weighing} =
      Akrasia.Weighings.create_weighing(
        scope,
        Enum.into(attrs, %{date: ~D[2026-11-01], weight: "80.0"})
      )

    weighing
  end

  @doc "A confirmed user with a profile (name, height, public, target)."
  def profile_user_fixture(profile \\ %{}) do
    user = AccountsFixtures.user_fixture()

    {:ok, user} =
      Accounts.update_user_profile(
        user,
        Enum.into(profile, %{name: "Anna", height: "180", public: false})
      )

    user
  end
end
