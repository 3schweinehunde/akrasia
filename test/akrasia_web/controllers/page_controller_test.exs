defmodule AkrasiaWeb.PageControllerTest do
  use AkrasiaWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, ~p"/")
    assert html_response(conn, 200) =~ "BMI Monitor"
  end

  test "GET /imprint", %{conn: conn} do
    conn = get(conn, ~p"/imprint")
    assert html_response(conn, 200) =~ "Imprint"
  end

  test "GET /privacy", %{conn: conn} do
    conn = get(conn, ~p"/privacy")
    assert html_response(conn, 200) =~ "Privacy Policy"
  end

  test "the old /page/:template route is gone", %{conn: conn} do
    conn = get(conn, "/page/imprint")
    assert html_response(conn, 404)
  end
end
