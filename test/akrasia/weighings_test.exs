defmodule Akrasia.WeighingsTest do
  use Akrasia.DataCase, async: true

  import Akrasia.WeighingsFixtures

  alias Akrasia.Accounts.Scope
  alias Akrasia.Weighings
  alias Akrasia.Weighings.Weighing

  setup do
    user = profile_user_fixture()
    %{user: user, scope: Scope.for_user(user)}
  end

  describe "scoping" do
    test "users only see and change their own weighings", %{scope: scope} do
      other = Scope.for_user(profile_user_fixture())
      mine = weighing_fixture(scope)
      theirs = weighing_fixture(other)

      assert [%Weighing{id: id}] = Weighings.list_weighings(scope)
      assert id == mine.id
      assert Weighings.count_weighings(scope) == 1

      assert_raise Ecto.NoResultsError, fn -> Weighings.get_weighing!(scope, theirs.id) end
      assert_raise MatchError, fn -> Weighings.update_weighing(scope, theirs, %{weight: 1}) end
      assert_raise MatchError, fn -> Weighings.delete_weighing(scope, theirs) end
    end

    test "user_id can not be set through attrs", %{scope: scope} do
      other = profile_user_fixture()

      {:ok, weighing} =
        Weighings.create_weighing(scope, %{date: ~D[2026-01-01], weight: 70, user_id: other.id})

      assert weighing.user_id == scope.user.id
    end
  end

  describe "list_weighings/2" do
    test "sorts by allowed fields and pages", %{scope: scope} do
      for {day, weight} <- [{1, "82"}, {2, "80"}, {3, "81"}] do
        weighing_fixture(scope, %{date: Date.new!(2026, 1, day), weight: weight})
      end

      dates = fn list -> Enum.map(list, & &1.date.day) end

      assert dates.(Weighings.list_weighings(scope)) == [3, 2, 1]

      assert dates.(Weighings.list_weighings(scope, sort_by: :weight, sort_order: :asc)) == [
               2,
               3,
               1
             ]

      assert dates.(Weighings.list_weighings(scope, per_page: 2, page: 2)) == [1]
    end

    test "refuses other sort fields", %{scope: scope} do
      assert_raise ArgumentError, fn -> Weighings.list_weighings(scope, sort_by: :user_id) end
    end
  end

  describe "validation" do
    test "requires date and weight", %{scope: scope} do
      assert {:error, changeset} = Weighings.create_weighing(scope, %{})
      assert %{date: ["can't be blank"], weight: ["can't be blank"]} = errors_on(changeset)
    end
  end

  describe "BMI" do
    test "bmi/2 rounds to two decimals and needs a height" do
      assert Weighings.bmi(Decimal.new("80"), Decimal.new("180")) == 24.69
      assert Weighings.bmi(Decimal.new("80"), nil) == nil
    end

    test "bmi_series/1 is ordered by date", %{user: user, scope: scope} do
      weighing_fixture(scope, %{date: ~D[2026-02-01], weight: "81"})
      weighing_fixture(scope, %{date: ~D[2026-01-01], weight: "80"})

      assert Weighings.bmi_series(user) == [["2026-01-01", 24.69], ["2026-02-01", 25.0]]
    end

    test "bmi_series/1 is empty without a height", %{scope: scope} do
      weighing_fixture(scope)
      user = %{scope.user | height: nil}

      assert Weighings.bmi_series(user) == []
    end

    test "target_bmi/1", %{user: user} do
      assert Weighings.target_bmi(%{user | target: nil}) == nil
      assert Weighings.target_bmi(%{user | target: Decimal.new("72.9")}) == 22.5
    end
  end

  describe "comparators" do
    test "only public users with a height, never oneself", %{scope: scope} do
      public = profile_user_fixture(%{name: "Public", public: true})
      _private = profile_user_fixture(%{name: "Private", public: false})
      _no_height = profile_user_fixture(%{name: "No height", public: true, height: nil})

      assert [%{name: "Public"}] = Weighings.list_comparators(scope)
      assert Weighings.get_comparator(scope, public.id).id == public.id
    end

    test "get_comparator/2 refuses private users and bad ids", %{scope: scope} do
      private = profile_user_fixture(%{public: false})

      assert Weighings.get_comparator(scope, private.id) == nil
      assert Weighings.get_comparator(scope, "1 OR 1=1") == nil
    end
  end
end
