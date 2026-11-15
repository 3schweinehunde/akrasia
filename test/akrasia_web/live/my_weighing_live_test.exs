defmodule AkrasiaWeb.MyWeighingLiveTest do
  use AkrasiaWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import Akrasia.WeighingsFixtures

  alias Akrasia.Accounts.Scope
  alias Akrasia.Weighings

  setup %{conn: conn} do
    user = profile_user_fixture()
    %{conn: log_in_user(conn, user), scope: Scope.for_user(user)}
  end

  describe "index" do
    test "lists only the user's own weighings", %{conn: conn, scope: scope} do
      mine = weighing_fixture(scope, %{weight: "77.7"})
      other = weighing_fixture(Scope.for_user(profile_user_fixture()), %{weight: "99.9"})

      {:ok, lv, html} = live(conn, ~p"/weighings")

      assert has_element?(lv, "#weighing-#{mine.id}")
      refute has_element?(lv, "#weighing-#{other.id}")
      refute html =~ "99.9"
    end

    test "sorts by a column and ignores unknown sort params (#4)", %{conn: conn, scope: scope} do
      heavy = weighing_fixture(scope, %{date: ~D[2026-01-01], weight: "90"})
      light = weighing_fixture(scope, %{date: ~D[2026-01-02], weight: "70"})
      position = fn html, w -> :binary.match(html, "weighing-#{w.id}") end

      {:ok, _lv, html} = live(conn, ~p"/weighings?sort_by=weight&sort_order=asc")
      assert position.(html, light) < position.(html, heavy)

      # unknown params fall back to date, newest first
      {:ok, _lv, html} = live(conn, ~p"/weighings?sort_by=no_such_field&sort_order=up")
      assert position.(html, light) < position.(html, heavy)

      {:ok, _lv, html} = live(conn, ~p"/weighings?sort_by=date&sort_order=asc")
      assert position.(html, heavy) < position.(html, light)
    end

    test "deletes a weighing", %{conn: conn, scope: scope} do
      weighing = weighing_fixture(scope)
      {:ok, lv, _html} = live(conn, ~p"/weighings")

      assert lv |> element("#weighing-#{weighing.id} a", "Delete") |> render_click() =~
               "Weighing deleted."

      assert Weighings.count_weighings(scope) == 0
    end
  end

  describe "form" do
    test "creates a weighing with the optional fields", %{conn: conn, scope: scope} do
      {:ok, lv, _html} = live(conn, ~p"/weighings/new")

      {:ok, _lv, html} =
        lv
        |> form("#weighing-form",
          weighing: %{date: "2026-11-11", weight: "75.5", abdominal_girth: "90", adipose: "21.5"}
        )
        |> render_submit()
        |> follow_redirect(conn, ~p"/weighings")

      assert html =~ "Weighing created."
      assert [%{abdominal_girth: 90}] = Weighings.list_weighings(scope)
    end

    test "edits a weighing", %{conn: conn, scope: scope} do
      weighing = weighing_fixture(scope)
      {:ok, lv, _html} = live(conn, ~p"/weighings/#{weighing}/edit")

      {:ok, _lv, html} =
        lv
        |> form("#weighing-form", weighing: %{weight: "70.1"})
        |> render_submit()
        |> follow_redirect(conn, ~p"/weighings")

      assert html =~ "Weighing updated."

      assert Decimal.equal?(
               Weighings.get_weighing!(scope, weighing.id).weight,
               Decimal.new("70.1")
             )
    end

    test "can't edit other users' weighings", %{conn: conn} do
      other = weighing_fixture(Scope.for_user(profile_user_fixture()))

      assert_raise Ecto.NoResultsError, fn -> live(conn, ~p"/weighings/#{other}/edit") end
    end
  end
end
