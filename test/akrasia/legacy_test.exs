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

  describe "users" do
    alias Akrasia.Legacy.User

    @valid_attrs %{admin: true, created_at: ~N[2010-04-17 14:00:00], email: "some email", hashed_password: "some hashed_password", height: 42, id: 42, invitation_id: 42, invitation_limit: 42, public: true, salt: "some salt", target: "120.5", updated_at: ~N[2010-04-17 14:00:00]}
    @update_attrs %{admin: false, created_at: ~N[2011-05-18 15:01:01], email: "some updated email", hashed_password: "some updated hashed_password", height: 43, id: 43, invitation_id: 43, invitation_limit: 43, public: false, salt: "some updated salt", target: "456.7", updated_at: ~N[2011-05-18 15:01:01]}
    @invalid_attrs %{admin: nil, created_at: nil, email: nil, hashed_password: nil, height: nil, id: nil, invitation_id: nil, invitation_limit: nil, public: nil, salt: nil, target: nil, updated_at: nil}

    def user_fixture(attrs \\ %{}) do
      {:ok, user} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Legacy.create_user()

      user
    end

    test "list_users/0 returns all users" do
      user = user_fixture()
      assert Legacy.list_users() == [user]
    end

    test "get_user!/1 returns the user with given id" do
      user = user_fixture()
      assert Legacy.get_user!(user.id) == user
    end

    test "create_user/1 with valid data creates a user" do
      assert {:ok, %User{} = user} = Legacy.create_user(@valid_attrs)
      assert user.admin == true
      assert user.created_at == ~N[2010-04-17 14:00:00]
      assert user.email == "some email"
      assert user.hashed_password == "some hashed_password"
      assert user.height == 42
      assert user.id == 42
      assert user.invitation_id == 42
      assert user.invitation_limit == 42
      assert user.public == true
      assert user.salt == "some salt"
      assert user.target == Decimal.new("120.5")
      assert user.updated_at == ~N[2010-04-17 14:00:00]
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Legacy.create_user(@invalid_attrs)
    end

    test "update_user/2 with valid data updates the user" do
      user = user_fixture()
      assert {:ok, %User{} = user} = Legacy.update_user(user, @update_attrs)
      assert user.admin == false
      assert user.created_at == ~N[2011-05-18 15:01:01]
      assert user.email == "some updated email"
      assert user.hashed_password == "some updated hashed_password"
      assert user.height == 43
      assert user.id == 43
      assert user.invitation_id == 43
      assert user.invitation_limit == 43
      assert user.public == false
      assert user.salt == "some updated salt"
      assert user.target == Decimal.new("456.7")
      assert user.updated_at == ~N[2011-05-18 15:01:01]
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = user_fixture()
      assert {:error, %Ecto.Changeset{}} = Legacy.update_user(user, @invalid_attrs)
      assert user == Legacy.get_user!(user.id)
    end

    test "delete_user/1 deletes the user" do
      user = user_fixture()
      assert {:ok, %User{}} = Legacy.delete_user(user)
      assert_raise Ecto.NoResultsError, fn -> Legacy.get_user!(user.id) end
    end

    test "change_user/1 returns a user changeset" do
      user = user_fixture()
      assert %Ecto.Changeset{} = Legacy.change_user(user)
    end
  end
end
