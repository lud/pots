defmodule Pots.ModelTest do
  alias Pots.Model
  alias Pots.Model.IngredientStock
  alias Pots.Repo
  import Pots.ModelFixtures
  use Pots.DataCase

  describe "wealth" do
    test "currency 1 is always defined with amount 100 on fresh app" do
      assert 100 = Model.fetch_wealth!()
      assert 0 = Model.update_wealth!(-100)
      assert 10 = Model.update_wealth!(+10)
      assert 12 = Model.update_wealth!(+2)
      assert 0 = Model.update_wealth!(-12)

      # cannot go below zero
      assert_raise Ecto.InvalidChangesetError, fn ->
        Model.update_wealth!(-1) |> dbg()
      end
    end
  end

  describe "ingredients" do
    test "calling fetch_ingredient_stock!/1 with any id returns zero if unknown" do
      assert 0 = Model.fetch_ingredient_stock!(123)
    end

    test "calling fetch_ingredient_stock!/1 with a previously set stock returns that number" do
      {:ok, _stock} = Repo.insert(%IngredientStock{id: 456, amount: 25})
      assert 25 = Model.fetch_ingredient_stock!(456)
    end

    test "calling update_ingredient_stock!/2 with id and amount updates the amount" do
      id = 789

      {:ok, _stock} = Repo.insert(%IngredientStock{id: id, amount: 10})

      assert 15 = Model.update_ingredient_stock!(id, 5)
      assert 15 = Model.fetch_ingredient_stock!(id)

      assert 12 = Model.update_ingredient_stock!(id, -3)
      assert 12 = Model.fetch_ingredient_stock!(id)
    end

    test "calling update_ingredient_stock!/2 leading to negative amount raises an error" do
      ingredient_stock_fixture(%{id: 999, amount: 5})

      assert_raise Ecto.InvalidChangesetError, fn ->
        Model.update_ingredient_stock!(999, -10)
      end

      assert_raise Ecto.InvalidChangesetError, fn ->
        Model.update_ingredient_stock!(888, -1)
      end
    end

    test "calling update_ingredient_stock!/2 on non-existing ingredient with positive amount succeeds" do
      assert 15 = Model.update_ingredient_stock!(111, 15)
      assert 15 = Model.fetch_ingredient_stock!(111)
    end

    test "calling update_ingredient_stock!/2 on non-existing ingredient with zero amount succeeds" do
      assert 0 = Model.update_ingredient_stock!(222, 0)
      assert 0 = Model.fetch_ingredient_stock!(222)
    end

    test "calling update_ingredient_stock!/2 on non-existing ingredient with negative amount fails" do
      assert_raise Ecto.InvalidChangesetError, fn ->
        Model.update_ingredient_stock!(333, -5)
      end
    end
  end

  describe "buy_ingredient/2" do
    test "decreases wealth and increases ingredient stock on success" do
      ingredient_id = 1
      amount = 1
      # Green Tea costs 100 per unit
      expected_cost = 100 * amount

      initial_wealth = Model.fetch_wealth!()
      initial_stock = Model.fetch_ingredient_stock!(ingredient_id)

      assert {:ok, {new_wealth, new_stock}} = Model.buy_ingredient(ingredient_id, amount)

      # Check wealth decreased by correct amount
      assert Model.fetch_wealth!() == initial_wealth - expected_cost
      assert Model.fetch_wealth!() == new_wealth

      # Check stock increased by correct amount
      assert new_stock == initial_stock + amount
      assert Model.fetch_ingredient_stock!(ingredient_id) == new_stock
    end

    test "can buy multiple units when sufficient wealth is available" do
      ingredient_id = 1
      amount = 3
      # 300 total cost
      expected_cost = 100 * amount

      # Add enough wealth to afford the purchase
      # Now we have 400 total wealth
      Model.update_wealth!(300)

      initial_wealth = Model.fetch_wealth!()
      initial_stock = Model.fetch_ingredient_stock!(ingredient_id)

      assert {:ok, {new_wealth, new_stock}} = Model.buy_ingredient(ingredient_id, amount)

      # Check wealth decreased by correct amount
      assert Model.fetch_wealth!() == initial_wealth - expected_cost
      assert Model.fetch_wealth!() == new_wealth

      # Check stock increased by correct amount
      assert new_stock == initial_stock + amount
      assert Model.fetch_ingredient_stock!(ingredient_id) == new_stock
    end

    test "returns error when not affordable" do
      ingredient_id = 1
      # 2 units at 100 each = 200, but we only have 100 wealth
      amount = 2

      # Ensure we have exactly 100 wealth (the default)
      initial_wealth = Model.fetch_wealth!()
      assert initial_wealth == 100

      initial_stock = Model.fetch_ingredient_stock!(ingredient_id)

      assert {:error, :not_enough_wealth} = Model.buy_ingredient(ingredient_id, amount)

      # Check that nothing changed
      assert Model.fetch_wealth!() == initial_wealth
      assert Model.fetch_ingredient_stock!(ingredient_id) == initial_stock
    end

    test "returns error for non-existent ingredient" do
      non_existent_id = 999
      amount = 1

      initial_wealth = Model.fetch_wealth!()

      assert {:error, :not_found} = Model.buy_ingredient(non_existent_id, amount)

      # Check that wealth didn't change
      assert Model.fetch_wealth!() == initial_wealth
    end
  end
end
