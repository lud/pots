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

  describe "list_ingredient_stock/0" do
    test "returns empty map when no ingredients are stocked" do
      assert %{} == Model.list_ingredient_stock()
    end

    test "returns map with ingredient ids and amounts" do
      ingredient_stock_fixture(%{id: 1, amount: 10})
      ingredient_stock_fixture(%{id: 3, amount: 5})
      ingredient_stock_fixture(%{id: 15, amount: 25})

      stock_map = Model.list_ingredient_stock()

      assert stock_map == %{1 => 10, 3 => 5, 15 => 25}
    end

    test "returns updated map after stock changes" do
      # Start with some stock
      # Dandelion Leaf
      ingredient_stock_fixture(%{id: 2, amount: 8})

      initial_stock = Model.list_ingredient_stock()
      assert initial_stock == %{2 => 8}

      Model.update_ingredient_stock!(2, 7)
      Model.update_ingredient_stock!(4, 3)

      updated_stock = Model.list_ingredient_stock()
      assert updated_stock == %{2 => 15, 4 => 3}
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
      initial_stock_list = Model.list_ingredient_stock()

      assert {:ok, {new_wealth, new_stock}} = Model.buy_ingredient(ingredient_id, amount)

      assert Model.fetch_wealth!() == initial_wealth - expected_cost
      assert Model.fetch_wealth!() == new_wealth

      assert new_stock == initial_stock + amount
      assert Model.fetch_ingredient_stock!(ingredient_id) == new_stock

      updated_stock_list = Model.list_ingredient_stock()
      expected_new_amount = initial_stock + amount
      assert Map.get(updated_stock_list, ingredient_id) == expected_new_amount

      # If this was the first time buying this ingredient, the map should now contain it
      if initial_stock == 0 do
        refute Map.has_key?(initial_stock_list, ingredient_id)
        assert Map.has_key?(updated_stock_list, ingredient_id)
      end
    end

    test "can buy multiple units when sufficient wealth is available" do
      ingredient_id = 1
      amount = 3
      expected_cost = 100 * amount

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

      # Check that list_ingredient_stock shows the updated inventory
      updated_stock_list = Model.list_ingredient_stock()
      expected_new_amount = initial_stock + amount
      assert Map.get(updated_stock_list, ingredient_id) == expected_new_amount
    end

    test "returns error when not affordable" do
      ingredient_id = 1
      amount = 2

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

      assert Model.fetch_wealth!() == initial_wealth
    end

    test "buying different ingredients updates the inventory list correctly" do
      # Start with lots of wealth to afford multiple purchases
      Model.update_wealth!(999_999)

      assert %{} = Model.list_ingredient_stock()

      assert {:ok, {_wealth1, stock1}} = Model.buy_ingredient(1, 2)
      assert stock1 == 2

      inventory_after_tea = Model.list_ingredient_stock()
      assert inventory_after_tea == %{1 => 2}

      assert {:ok, {_wealth2, stock2}} = Model.buy_ingredient(2, 5)
      assert stock2 == 5

      inventory_after_dandelion = Model.list_ingredient_stock()
      assert inventory_after_dandelion == %{1 => 2, 2 => 5}

      assert {:ok, {_wealth3, stock3}} = Model.buy_ingredient(1, 1)
      assert stock3 == 3

      final_inventory = Model.list_ingredient_stock()
      assert final_inventory == %{1 => 3, 2 => 5}
    end
  end

  describe "buy books" do
  end

  describe "recipes" do
    alias Pots.Model.KnownRecipe

    import Pots.ModelFixtures

    @invalid_attrs %{name: nil, description: nil, components: nil, price: nil}

    test "list_recipes/0 returns all recipes" do
      known_recipe = known_recipe_fixture()
      assert Model.list_recipes() == [known_recipe]
    end

    test "get_known_recipe!/1 returns the known_recipe with given id" do
      known_recipe = known_recipe_fixture()
      assert Model.get_known_recipe!(known_recipe.id) == known_recipe
    end

    test "create_known_recipe/1 with valid data creates a known_recipe" do
      valid_attrs = %{
        name: "some name",
        description: "some description",
        components: [%{type: :ingredient, id: 123, amount: 456}],
        price: 42
      }

      assert {:ok, %KnownRecipe{} = known_recipe} = Model.create_known_recipe(valid_attrs)
      assert "some name" == known_recipe.name
      assert "some description" == known_recipe.description

      assert [
               %Pots.Model.KnownRecipe.Component{
                 id: 123,
                 type: :ingredient,
                 amount: 456
               }
             ] == known_recipe.components

      assert 42 == known_recipe.price
    end

    test "create_known_recipe/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Model.create_known_recipe(@invalid_attrs)
    end
  end
end
