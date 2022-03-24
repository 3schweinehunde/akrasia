defmodule AkrasiaWeb.WeighingControllerTest do
  use AkrasiaWeb.ConnCase

  alias Akrasia.Accounts

  @create_attrs %{
    abdominal_girth: 42,
    adipose: "120.5",
    date: ~N[2010-04-17 14:00:00],
    weight: "120.5"
  }
  @update_attrs %{
    abdominal_girth: 43,
    adipose: "456.7",
    date: ~N[2011-05-18 15:01:01],
    weight: "456.7"
  }
  @invalid_attrs %{abdominal_girth: nil, adipose: nil, date: nil, weight: nil}

  def fixture(:weighing) do
    {:ok, weighing} = Accounts.create_weighing(@create_attrs)
    weighing
  end

  describe "index" do
    test "lists all weighings", %{conn: conn} do
      conn = get(conn, Routes.weighing_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Weighings"
    end
  end

  describe "new weighing" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.weighing_path(conn, :new))
      assert html_response(conn, 200) =~ "New Weighing"
    end
  end

  describe "create weighing" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.weighing_path(conn, :create), weighing: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.weighing_path(conn, :show, id)

      conn = get(conn, Routes.weighing_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Weighing"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.weighing_path(conn, :create), weighing: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Weighing"
    end
  end

  describe "edit weighing" do
    setup [:create_weighing]

    test "renders form for editing chosen weighing", %{conn: conn, weighing: weighing} do
      conn = get(conn, Routes.weighing_path(conn, :edit, weighing))
      assert html_response(conn, 200) =~ "Edit Weighing"
    end
  end

  describe "update weighing" do
    setup [:create_weighing]

    test "redirects when data is valid", %{conn: conn, weighing: weighing} do
      conn = put(conn, Routes.weighing_path(conn, :update, weighing), weighing: @update_attrs)
      assert redirected_to(conn) == Routes.weighing_path(conn, :show, weighing)

      conn = get(conn, Routes.weighing_path(conn, :show, weighing))
      assert html_response(conn, 200)
    end

    test "renders errors when data is invalid", %{conn: conn, weighing: weighing} do
      conn = put(conn, Routes.weighing_path(conn, :update, weighing), weighing: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Weighing"
    end
  end

  describe "delete weighing" do
    setup [:create_weighing]

    test "deletes chosen weighing", %{conn: conn, weighing: weighing} do
      conn = delete(conn, Routes.weighing_path(conn, :delete, weighing))
      assert redirected_to(conn) == Routes.weighing_path(conn, :index)

      assert_error_sent 404, fn ->
        get(conn, Routes.weighing_path(conn, :show, weighing))
      end
    end
  end

  defp create_weighing(_) do
    weighing = fixture(:weighing)
    %{weighing: weighing}
  end
end
