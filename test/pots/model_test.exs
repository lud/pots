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
end
