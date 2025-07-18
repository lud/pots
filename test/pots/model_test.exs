defmodule Pots.ModelTest do
  alias Pots.Model
  alias Pots.Model.IngredientStock
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
    test "calling fetch_ingredient_stock!/1 with any id returns zero if unknown"
    test "calling fetch_ingredient_stock!/1 with a previously set stock returns that number"
    test "calling update_ingredient_stock!/2 with id and amount updates the amount"
    test "calling update_ingredient_stock!/2 leading to negative amount raises an error"
  end
end
