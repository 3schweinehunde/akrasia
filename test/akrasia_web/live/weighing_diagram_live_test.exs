defmodule AkrasiaWeb.WeighingDiagramLiveTest do
  use AkrasiaWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import Akrasia.WeighingsFixtures

  alias Akrasia.Accounts.Scope

  defp log_in(conn, user), do: log_in_user(conn, user)

  test "redirects to the login page when not logged in", %{conn: conn} do
    assert {:error, {:redirect, %{to: "/users/log-in"}}} = live(conn, ~p"/diagram")
  end

  test "no crash without weighings or height (#1)", %{conn: conn} do
    user = profile_user_fixture(%{height: nil})

    {:ok, _lv, html} = conn |> log_in(user) |> live(~p"/diagram")

    assert html =~ "Enter your height in your profile"
  end

  test "no crash without weighings, with height (#1)", %{conn: conn} do
    {:ok, _lv, html} = conn |> log_in(profile_user_fixture()) |> live(~p"/diagram")

    assert html =~ "No weighings yet"
  end

  test "renders the BMI series and the target BMI", %{conn: conn} do
    user = profile_user_fixture(%{target: "72.9"})
    weighing_fixture(Scope.for_user(user), %{date: ~D[2026-01-01], weight: "80"})

    {:ok, lv, _html} = conn |> log_in(user) |> live(~p"/diagram")

    chart = lv |> element("#bmi-chart") |> render()
    assert chart =~ ~s(data-series="[[&quot;2026-01-01&quot;,24.69]]")
    assert chart =~ ~s(data-target-bmi="22.5")
  end

  test "saving a weighing resets the form and updates the last weighing (#2)", %{conn: conn} do
    user = profile_user_fixture()
    {:ok, lv, _html} = conn |> log_in(user) |> live(~p"/diagram")

    html =
      lv
      |> form("#weighing-form", weighing: %{date: "2026-11-10", weight: "79.5"})
      |> render_submit()

    assert html =~ "Weighing saved."
    assert lv |> element("#last-weighing") |> render() =~ "2026-11-10: 79.5 kg"
    assert_push_event lv, "user-series", %{data: [["2026-11-10", 24.54]]}
    # fresh form: today's date
    assert lv |> element("#weighing-form") |> render() =~ Date.to_iso8601(Date.utc_today())
  end

  test "shows validation errors", %{conn: conn} do
    {:ok, lv, _html} = conn |> log_in(profile_user_fixture()) |> live(~p"/diagram")

    html =
      lv
      |> form("#weighing-form", weighing: %{date: "2026-11-10", weight: ""})
      |> render_submit()

    assert html =~ "can&#39;t be blank"
  end

  test "compares with a public user and back", %{conn: conn} do
    comparator = profile_user_fixture(%{name: "Berta", public: true})
    weighing_fixture(Scope.for_user(comparator), %{date: ~D[2026-01-01], weight: "90"})

    {:ok, lv, _html} = conn |> log_in(profile_user_fixture()) |> live(~p"/diagram")

    lv |> element("#comparators button", "Berta") |> render_click()
    assert_push_event lv, "comparator-series", %{name: "Berta", data: [["2026-01-01", 27.78]]}

    lv |> element("#comparators button", "Nobody") |> render_click()
    assert_push_event lv, "comparator-series", %{name: nil, data: []}
  end

  test "private users are neither listed nor loadable", %{conn: conn} do
    private = profile_user_fixture(%{name: "Secret", public: false})

    {:ok, lv, html} = conn |> log_in(profile_user_fixture()) |> live(~p"/diagram")

    refute html =~ "Secret"

    # a private or forged id sent by a client is ignored
    render_hook(lv, "compare", %{"id" => to_string(private.id)})
    render_hook(lv, "compare", %{"id" => "not-a-number"})
    refute_push_event lv, "comparator-series", %{}
  end
end
