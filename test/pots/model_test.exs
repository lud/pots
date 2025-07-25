defmodule Pots.ModelTest do
  alias Pots.Data
  alias Pots.Data.Ingredients
  alias Pots.Model
  alias Pots.Model.IngredientStock
  alias Pots.Model.KnownRecipe
  alias Pots.Model.OwnedBook
  alias Pots.Repo
  import Pots.ModelFixtures
  use Pots.DataCase

  describe "wealth" do
    test "currency 1 is always defined with amount 1 on fresh app" do
      assert 1 = Model.fetch_wealth!()
      assert 0 = Model.update_wealth!(-1)
      assert 10 = Model.update_wealth!(+10)
      assert 12 = Model.update_wealth!(+2)
      assert 0 = Model.update_wealth!(-12)

      # cannot go below zero
      assert_raise Ecto.InvalidChangesetError, fn ->
        Model.update_wealth!(-1)
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
      assert %{2 => 8} == initial_stock
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

      expected_cost = Ingredients.fetch!(1).price * amount

      initial_wealth = Model.reset_wealth!(expected_cost + 10)
      initial_stock = Model.fetch_ingredient_stock!(ingredient_id)
      initial_stock_list = Model.list_ingredient_stock()

      assert {:ok, {new_wealth, new_stock}} = Model.buy_ingredient(ingredient_id, amount)

      assert initial_wealth - expected_cost == Model.fetch_wealth!()
      assert new_wealth == Model.fetch_wealth!()

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
      expected_cost = Data.Ingredients.fetch!(ingredient_id).price * amount

      initial_wealth = Model.reset_wealth!(expected_cost + 10)

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
      assert initial_wealth == 1

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
      Model.reset_wealth!(999_999)

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
    test "buy_book/1 with sufficient wealth adds recipes to known recipes and decreases wealth" do
      # Book 1 is "Torn Shopping List" which costs 0 and has 2 recipes
      book_id = 1
      expected_cost = 0

      initial_wealth = Model.fetch_wealth!()
      initial_recipes = Model.list_recipes()
      initial_owned_books = Model.list_owned_books()
      assert initial_recipes == []
      assert initial_owned_books == []

      assert {:ok, {new_wealth, added_recipes}} = Model.buy_book(book_id)

      # Check wealth decreased by correct amount
      assert new_wealth == initial_wealth - expected_cost
      assert Model.fetch_wealth!() == new_wealth

      # Check that recipes were added
      assert length(added_recipes) == 2

      # Verify the added recipes are in the known recipes
      known_recipes = Model.list_recipes()
      assert length(known_recipes) == 2

      # Check that the book is now owned
      owned_books = Model.list_owned_books()
      assert length(owned_books) == 1
      assert List.first(owned_books).id == book_id

      # Check that the recipes match what we expect from the book
      recipe_names = Enum.map(known_recipes, & &1.name) |> Enum.sort()
      assert recipe_names == ["Mint Tea", "Tea"]

      # Verify recipe contents for Tea
      tea_recipe = Enum.find(known_recipes, &(&1.name == "Tea"))
      assert tea_recipe.description == "It's just Tea."

      [tea_component] = tea_recipe.components
      assert tea_component.type == :ingredient
      # Green Tea
      assert tea_component.id == 1
      assert tea_component.amount == 1

      # Verify recipe contents for Mint Tea
      mint_tea_recipe = Enum.find(known_recipes, &(&1.name == "Mint Tea"))
      assert mint_tea_recipe.description == "So sweet!"
    end

    test "buy_book/1 with insufficient wealth returns error and changes nothing" do
      book_id = 2

      # we do not have enough
      initial_wealth = Model.reset_wealth!(Data.Books.fetch!(book_id).price - 10)

      initial_recipes = Model.list_recipes()
      initial_owned_books = Model.list_owned_books()

      assert {:error, :not_enough_wealth} = Model.buy_book(book_id)

      # Check that nothing changed
      assert Model.fetch_wealth!() == initial_wealth
      assert Model.list_recipes() == initial_recipes
      assert Model.list_owned_books() == initial_owned_books
    end

    test "buy_book/1 with non-existent book returns error" do
      non_existent_id = 999

      initial_wealth = Model.fetch_wealth!()
      initial_recipes = Model.list_recipes()
      initial_owned_books = Model.list_owned_books()

      assert {:error, :not_found} = Model.buy_book(non_existent_id)

      # Check that nothing changed
      assert Model.fetch_wealth!() == initial_wealth
      assert Model.list_recipes() == initial_recipes
      assert Model.list_owned_books() == initial_owned_books
    end

    test "buying multiple books accumulates recipes correctly" do
      # Ensure we have enough wealth
      Model.reset_wealth!(2000)

      # Buy first book (Torn Shopping List - 2 recipes, costs 0)
      assert {:ok, {_wealth1, recipes1}} = Model.buy_book(1)
      assert length(recipes1) == 2
      assert length(Model.list_recipes()) == 2
      assert length(Model.list_owned_books()) == 1

      # Buy second book (Faded Page of Scribbles - 0 recipes, costs 1000)
      #
      # TODO this book as no recipes for now so this generated test is stupid.
      # Fix later.
      assert {:ok, {_wealth2, recipes2}} = Model.buy_book(2)
      assert [] == recipes2
      # Still 2 recipes total
      assert [_, _] = Model.list_recipes()
      # Now 2 books owned
      assert [_, _] = Model.list_owned_books()

      # Verify we have the expected recipes
      final_recipes = Model.list_recipes()
      recipe_names = Enum.map(final_recipes, & &1.name) |> Enum.sort()
      assert recipe_names == ["Mint Tea", "Tea"]

      # Verify both books are owned
      owned_book_ids = Enum.map(Model.list_owned_books(), & &1.id) |> Enum.sort()
      assert owned_book_ids == [1, 2]
    end

    test "available_books/0 excludes owned books and prioritizes affordable ones" do
      # Buy the first book (free)
      assert {:ok, {_wealth, _recipes}} = Model.buy_book(1)

      Model.reset_wealth!(0)

      # Now available_books should exclude the owned book, and since we cannot
      # afford anything it lists only the first unknown book.
      assert [%{id: new_available_id}] = Model.available_books()
      assert new_available_id != 1

      # if we have a lot of money we can see more
      Model.reset_wealth!(999_999)
      assert [_, _, _ | _] = Model.available_books()
    end

    test "available_books/0 returns first unknown book even if not affordable" do
      # Reduce wealth to very low amount
      # Leave only 10 wealth
      Model.reset_wealth!(0)

      # Should still return at least one book (the first unknown one) even if we
      # cannot afford it
      assert [_] = Model.available_books()
    end
  end

  describe "recipes" do
    @invalid_attrs %{name: nil, description: nil, components: nil, price: nil}

    test "list_recipes/0 returns all recipes" do
      known_recipe = known_recipe_fixture()
      assert Model.list_recipes() == [known_recipe]
    end

    test "fetch_known_recipe!/1 returns the known_recipe with given id" do
      known_recipe = known_recipe_fixture()
      assert Model.fetch_known_recipe!(known_recipe.id) == known_recipe
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

  describe "books" do
    @invalid_attrs %{}

    test "list_books/0 returns all books" do
      owned_books = owned_books_fixture()
      assert Model.list_owned_books() == [owned_books]
    end

    test "fetch_owned_book!/1 returns the owned_books with given id" do
      owned_books = owned_books_fixture()
      assert ^owned_books = Model.fetch_owned_book!(owned_books.id)
    end

    test "create_owned_book/1 with valid data creates a owned_books" do
      valid_attrs = %{id: 123}

      assert {:ok, %OwnedBook{}} = Model.create_owned_book(valid_attrs)
    end

    test "create_owned_book/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Model.create_owned_book(@invalid_attrs)
    end
  end
end
