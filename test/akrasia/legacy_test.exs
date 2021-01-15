defmodule Akrasia.LegacyTest do
  use Akrasia.DataCase

  alias Akrasia.Legacy

  describe "weighings" do
    alias Akrasia.Legacy.Weighing

    @valid_attrs %{date: ~D[2010-04-17], user_id: 42, weight: "120.5"}
    @update_attrs %{date: ~D[2011-05-18], user_id: 43, weight: "456.7"}
    @invalid_attrs %{date: nil, user_id: nil, weight: nil}

    def weighing_fixture(attrs \\ %{}) do
      {:ok, weighing} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Legacy.create_weighing()

      weighing
    end

    test "list_weighings/0 returns all weighings" do
      weighing = weighing_fixture()
      assert Legacy.list_weighings() == [weighing]
    end

    test "get_weighing!/1 returns the weighing with given id" do
      weighing = weighing_fixture()
      assert Legacy.get_weighing!(weighing.id) == weighing
    end

    test "create_weighing/1 with valid data creates a weighing" do
      assert {:ok, %Weighing{} = weighing} = Legacy.create_weighing(@valid_attrs)
      assert weighing.date == ~D[2010-04-17]
      assert weighing.user_id == 42
      assert weighing.weight == Decimal.new("120.5")
    end

    test "create_weighing/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Legacy.create_weighing(@invalid_attrs)
    end

    test "update_weighing/2 with valid data updates the weighing" do
      weighing = weighing_fixture()
      assert {:ok, %Weighing{} = weighing} = Legacy.update_weighing(weighing, @update_attrs)
      assert weighing.date == ~D[2011-05-18]
      assert weighing.user_id == 43
      assert weighing.weight == Decimal.new("456.7")
    end

    test "update_weighing/2 with invalid data returns error changeset" do
      weighing = weighing_fixture()
      assert {:error, %Ecto.Changeset{}} = Legacy.update_weighing(weighing, @invalid_attrs)
      assert weighing == Legacy.get_weighing!(weighing.id)
    end

    test "delete_weighing/1 deletes the weighing" do
      weighing = weighing_fixture()
      assert {:ok, %Weighing{}} = Legacy.delete_weighing(weighing)
      assert_raise Ecto.NoResultsError, fn -> Legacy.get_weighing!(weighing.id) end
    end

    test "change_weighing/1 returns a weighing changeset" do
      weighing = weighing_fixture()
      assert %Ecto.Changeset{} = Legacy.change_weighing(weighing)
    end
  end

  describe "weighings" do
    alias Akrasia.Legacy.Weighing

    @valid_attrs %{date: ~D[2010-04-17], user_id: 42, weight: "120.5"}
    @update_attrs %{date: ~D[2011-05-18], user_id: 43, weight: "456.7"}
    @invalid_attrs %{date: nil, user_id: nil, weight: nil}

    def weighing_fixture(attrs \\ %{}) do
      {:ok, weighing} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Legacy.create_weighing()

      weighing
    end

    test "list_weighings/0 returns all weighings" do
      weighing = weighing_fixture()
      assert Legacy.list_weighings() == [weighing]
    end

    test "get_weighing!/1 returns the weighing with given id" do
      weighing = weighing_fixture()
      assert Legacy.get_weighing!(weighing.id) == weighing
    end

    test "create_weighing/1 with valid data creates a weighing" do
      assert {:ok, %Weighing{} = weighing} = Legacy.create_weighing(@valid_attrs)
      assert weighing.date == ~D[2010-04-17]
      assert weighing.user_id == 42
      assert weighing.weight == Decimal.new("120.5")
    end

    test "create_weighing/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Legacy.create_weighing(@invalid_attrs)
    end

    test "update_weighing/2 with valid data updates the weighing" do
      weighing = weighing_fixture()
      assert {:ok, %Weighing{} = weighing} = Legacy.update_weighing(weighing, @update_attrs)
      assert weighing.date == ~D[2011-05-18]
      assert weighing.user_id == 43
      assert weighing.weight == Decimal.new("456.7")
    end

    test "update_weighing/2 with invalid data returns error changeset" do
      weighing = weighing_fixture()
      assert {:error, %Ecto.Changeset{}} = Legacy.update_weighing(weighing, @invalid_attrs)
      assert weighing == Legacy.get_weighing!(weighing.id)
    end

    test "delete_weighing/1 deletes the weighing" do
      weighing = weighing_fixture()
      assert {:ok, %Weighing{}} = Legacy.delete_weighing(weighing)
      assert_raise Ecto.NoResultsError, fn -> Legacy.get_weighing!(weighing.id) end
    end

    test "change_weighing/1 returns a weighing changeset" do
      weighing = weighing_fixture()
      assert %Ecto.Changeset{} = Legacy.change_weighing(weighing)
    end
  end
end
