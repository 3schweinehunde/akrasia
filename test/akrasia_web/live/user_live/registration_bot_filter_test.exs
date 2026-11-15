defmodule AkrasiaWeb.UserLive.RegistrationBotFilterTest do
  # changes application env (bot filter and rate limit settings)
  use AkrasiaWeb.ConnCase, async: false

  import Phoenix.LiveViewTest
  import Akrasia.AccountsFixtures

  alias Akrasia.Accounts

  setup %{conn: conn} do
    # a client IP of its own, so earlier tests don't count against the limit
    ip = "10.0.#{:rand.uniform(250)}.#{System.unique_integer([:positive])}"
    {:ok, conn: put_req_header(conn, "x-real-ip", ip)}
  end

  defp put_env(key, value) do
    previous = Application.get_env(:akrasia, key)
    Application.put_env(:akrasia, key, value)
    on_exit(fn -> Application.put_env(:akrasia, key, previous) end)
  end

  defp submit(lv, attrs, extra \\ %{}) do
    lv
    |> form("#registration_form", user: attrs)
    |> render_submit(extra)
  end

  test "requires a name", %{conn: conn} do
    {:ok, lv, _html} = live(conn, ~p"/users/register")

    result = submit(lv, %{email: unique_user_email(), name: ""})

    assert result =~ "can&#39;t be blank"
  end

  test "registers a person with email and name", %{conn: conn} do
    email = unique_user_email()
    {:ok, lv, _html} = live(conn, ~p"/users/register")

    {:ok, _lv, html} =
      submit(lv, %{email: email, name: "Anna"}) |> follow_redirect(conn, ~p"/users/log-in")

    assert html =~ "An email was sent to #{email}"
    assert %{name: "Anna"} = Accounts.get_user_by_email(email)
  end

  test "a filled honeypot looks like success but creates no user", %{conn: conn} do
    email = unique_user_email()
    {:ok, lv, _html} = live(conn, ~p"/users/register")

    {:ok, _lv, html} =
      submit(lv, %{email: email, name: "Bot"}, %{"website" => "http://spam.example"})
      |> follow_redirect(conn, ~p"/users/log-in")

    assert html =~ "An email was sent to #{email}"
    refute Accounts.get_user_by_email(email)
  end

  test "a submit faster than the minimum time creates no user", %{conn: conn} do
    put_env(:signup_min_seconds, 60)
    email = unique_user_email()
    {:ok, lv, _html} = live(conn, ~p"/users/register")

    {:ok, _lv, html} =
      submit(lv, %{email: email, name: "Quick"}) |> follow_redirect(conn, ~p"/users/log-in")

    assert html =~ "An email was sent to #{email}"
    refute Accounts.get_user_by_email(email)
  end

  test "too many sign-ups from one IP are refused", %{conn: conn} do
    put_env(Akrasia.RateLimit, mail_limit: 2)

    for _ <- 1..2 do
      {:ok, lv, _html} = live(conn, ~p"/users/register")
      submit(lv, %{email: unique_user_email(), name: "Ok"})
    end

    email = unique_user_email()
    {:ok, lv, _html} = live(conn, ~p"/users/register")

    assert submit(lv, %{email: email, name: "One too many"}) =~ "Too many requests"
    refute Accounts.get_user_by_email(email)
  end

  test "too many magic-link requests from one IP are refused", %{conn: conn} do
    put_env(Akrasia.RateLimit, mail_limit: 1)
    user = user_fixture()
    {:ok, lv, _html} = live(conn, ~p"/users/log-in")

    lv |> form("#login_form_magic", user: %{email: user.email}) |> render_submit()

    {:ok, lv, _html} = live(conn, ~p"/users/log-in")

    assert lv |> form("#login_form_magic", user: %{email: user.email}) |> render_submit() =~
             "Too many requests"
  end
end
