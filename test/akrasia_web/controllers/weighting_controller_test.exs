defmodule AkrasiaWeb.WeightingControllerTest do
  use AkrasiaWeb.ConnCase

  alias Akrasia.Accounts

  @create_attrs %{abdominal_girth: 42, adipose: "120.5", date: ~N[2010-04-17 14:00:00], weight: "120.5"}
  @update_attrs %{abdominal_girth: 43, adipose: "456.7", date: ~N[2011-05-18 15:01:01], weight: "456.7"}
  @invalid_attrs %{abdominal_girth: nil, adipose: nil, date: nil, weight: nil}

  def fixture(:weighting) do
    {:ok, weighting} = Accounts.create_weighting(@create_attrs)
    weighting
  end

  describe "index" do
    test "lists all weightings", %{conn: conn} do
      conn = get(conn, Routes.weighting_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Weightings"
    end
  end

  describe "new weighting" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.weighting_path(conn, :new))
      assert html_response(conn, 200) =~ "New Weighting"
    end
  end

  describe "create weighting" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.weighting_path(conn, :create), weighting: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.weighting_path(conn, :show, id)

      conn = get(conn, Routes.weighting_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Weighting"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.weighting_path(conn, :create), weighting: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Weighting"
    end
  end

  describe "edit weighting" do
    setup [:create_weighting]

    test "renders form for editing chosen weighting", %{conn: conn, weighting: weighting} do
      conn = get(conn, Routes.weighting_path(conn, :edit, weighting))
      assert html_response(conn, 200) =~ "Edit Weighting"
    end
  end

  describe "update weighting" do
    setup [:create_weighting]

    test "redirects when data is valid", %{conn: conn, weighting: weighting} do
      conn = put(conn, Routes.weighting_path(conn, :update, weighting), weighting: @update_attrs)
      assert redirected_to(conn) == Routes.weighting_path(conn, :show, weighting)

      conn = get(conn, Routes.weighting_path(conn, :show, weighting))
      assert html_response(conn, 200)
    end

    test "renders errors when data is invalid", %{conn: conn, weighting: weighting} do
      conn = put(conn, Routes.weighting_path(conn, :update, weighting), weighting: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Weighting"
    end
  end

  describe "delete weighting" do
    setup [:create_weighting]

    test "deletes chosen weighting", %{conn: conn, weighting: weighting} do
      conn = delete(conn, Routes.weighting_path(conn, :delete, weighting))
      assert redirected_to(conn) == Routes.weighting_path(conn, :index)
      assert_error_sent 404, fn ->
        get(conn, Routes.weighting_path(conn, :show, weighting))
      end
    end
  end

  defp create_weighting(_) do
    weighting = fixture(:weighting)
    %{weighting: weighting}
  end
end
