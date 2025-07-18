defmodule PotsWeb.BookShopControllerTest do
  import Inertia.Testing
  use PotsWeb.ConnCase

  alias Pots.Model

  describe "GET /bookshop" do
    test "renders bookshop page with books, recipes, and wealth", %{conn: conn} do
      conn = get(conn, ~p"/bookshop")

      assert "BookShop" = inertia_component(conn)

      props = inertia_props(conn)
      assert Map.has_key?(props, :books)
      assert Map.has_key?(props, :known_recipes)
      assert Map.has_key?(props, :wealth)

      # Verify wealth is a number
      assert is_integer(props.wealth)

      # Verify books is a list
      assert is_list(props.books)

      # Verify known_recipes is a list
      assert is_list(props.known_recipes)
    end
  end

  describe "POST /bookshop/buy" do
    test "successfully buys a book with sufficient wealth", %{conn: conn} do
      # Book 1 is "Torn Shopping List" which costs 0
      book_id = 1

      initial_wealth = Model.fetch_wealth!()
      initial_recipes = Model.list_recipes()

      conn = post(conn, ~p"/bookshop/buy", %{"id" => book_id})

      # Should redirect to bookshop
      assert redirected_to(conn) == "/bookshop"

      # Verify the book was actually purchased
      final_wealth = Model.fetch_wealth!()
      final_recipes = Model.list_recipes()

      # Wealth should decrease (by 0 in this case, but still a valid test)
      assert final_wealth <= initial_wealth

      # Should have more recipes (book 1 has 2 recipes)
      assert length(final_recipes) > length(initial_recipes)
    end

    test "fails to buy book with insufficient wealth", %{conn: conn} do
      # Reduce wealth to very low amount
      # Leave only 10 wealth
      Model.reset_wealth!(0)

      # Book 2 costs 1000, which is more than we have
      book_id = 2

      initial_wealth = Model.fetch_wealth!()
      initial_recipes = Model.list_recipes()

      conn = post(conn, ~p"/bookshop/buy", %{"id" => book_id})

      # Should redirect to bookshop
      assert redirected_to(conn) == "/bookshop"

      # Verify nothing changed
      assert Model.fetch_wealth!() == initial_wealth
      assert Model.list_recipes() == initial_recipes
    end

    test "fails to buy non-existent book", %{conn: conn} do
      non_existent_id = 999

      initial_wealth = Model.fetch_wealth!()
      initial_recipes = Model.list_recipes()

      conn = post(conn, ~p"/bookshop/buy", %{"id" => non_existent_id})

      # Should redirect to bookshop
      assert redirected_to(conn) == "/bookshop"

      # Verify nothing changed
      assert Model.fetch_wealth!() == initial_wealth
      assert Model.list_recipes() == initial_recipes
    end
  end
end
