defmodule AkrasiaWeb.AdminAuthTest do
  @moduledoc "The admin checks in UserAuth (#5), used by the admin pages."
  use AkrasiaWeb.ConnCase, async: true

  import Akrasia.AccountsFixtures

  alias Akrasia.Accounts.Scope
  alias AkrasiaWeb.UserAuth

  setup %{conn: conn} do
    conn =
      conn
      |> Map.replace!(:secret_key_base, AkrasiaWeb.Endpoint.config(:secret_key_base))
      |> init_test_session(%{})

    %{conn: conn}
  end

  defp admin_fixture do
    user = user_fixture()
    {:ok, user} = user |> Ecto.Changeset.change(admin: true) |> Akrasia.Repo.update()
    user
  end

  describe "require_admin_user/2" do
    test "lets admins pass", %{conn: conn} do
      conn =
        conn
        |> assign(:current_scope, Scope.for_user(admin_fixture()))
        |> fetch_flash()
        |> UserAuth.require_admin_user([])

      refute conn.halted
    end

    test "redirects other users", %{conn: conn} do
      conn =
        conn
        |> assign(:current_scope, Scope.for_user(user_fixture()))
        |> fetch_flash()
        |> UserAuth.require_admin_user([])

      assert conn.halted
      assert redirected_to(conn) == ~p"/"
    end

    test "redirects guests", %{conn: conn} do
      conn =
        conn
        |> assign(:current_scope, nil)
        |> fetch_flash()
        |> UserAuth.require_admin_user([])

      assert conn.halted
    end
  end

  describe "on_mount :require_admin" do
    defp socket do
      %Phoenix.LiveView.Socket{
        endpoint: AkrasiaWeb.Endpoint,
        assigns: %{__changed__: %{}, flash: %{}}
      }
    end

    defp session_for(user) do
      %{"user_token" => Akrasia.Accounts.generate_user_session_token(user)}
    end

    test "continues for admins" do
      assert {:cont, _socket} =
               UserAuth.on_mount(:require_admin, %{}, session_for(admin_fixture()), socket())
    end

    test "halts for other users" do
      assert {:halt, _socket} =
               UserAuth.on_mount(:require_admin, %{}, session_for(user_fixture()), socket())
    end

    test "halts without a session" do
      assert {:halt, _socket} = UserAuth.on_mount(:require_admin, %{}, %{}, socket())
    end
  end
end
