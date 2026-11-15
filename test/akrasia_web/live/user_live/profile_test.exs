defmodule AkrasiaWeb.UserLive.ProfileTest do
  use AkrasiaWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  alias Akrasia.Accounts

  test "redirects to the login page when not logged in", %{conn: conn} do
    assert {:error, {:redirect, %{to: "/users/log-in"}}} = live(conn, ~p"/users/profile")
  end

  describe "logged in" do
    setup :register_and_log_in_user

    test "updates name, height, public and target", %{conn: conn, user: user} do
      {:ok, lv, _html} = live(conn, ~p"/users/profile")

      html =
        lv
        |> form("#profile_form",
          user: %{name: "Berta", height: "172", public: "true", target: "68.5"}
        )
        |> render_submit()

      assert html =~ "Profile saved."
      user = Accounts.get_user!(user.id)
      assert user.name == "Berta"
      assert Decimal.equal?(user.height, 172)
      assert user.public
      assert Decimal.equal?(user.target, Decimal.new("68.5"))
    end

    test "shows validation errors", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/users/profile")

      html =
        lv
        |> form("#profile_form", user: %{name: "", height: "10"})
        |> render_change()

      assert html =~ "can&#39;t be blank"
      assert html =~ "must be greater than 50"
    end

    test "does not need sudo mode", %{conn: conn} do
      # logged in long ago: settings would ask to re-authenticate
      conn =
        log_in_user(build_conn(), Akrasia.AccountsFixtures.user_fixture(),
          token_authenticated_at: DateTime.add(DateTime.utc_now(:second), -2, :day)
        )

      assert {:ok, _lv, _html} = live(conn, ~p"/users/profile")
    end
  end

  describe "profile_changeset" do
    test "does not cast admin" do
      changeset = Accounts.change_user_profile(%Accounts.User{}, %{name: "X", admin: true})
      refute Ecto.Changeset.get_change(changeset, :admin)
    end
  end
end
