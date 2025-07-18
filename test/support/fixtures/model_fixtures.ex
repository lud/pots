defmodule Pots.ModelFixtures do
  @doc """
  Generate a ingredient_stock.
  """
  def ingredient_stock_fixture(attrs \\ %{}) do
    {:ok, ingredient_stock} =
      attrs
      |> Enum.into(%{amount: 42})
      |> Pots.Model.create_ingredient_stock()

    ingredient_stock
  end

  @doc """
  Generate a known_recipe.
  """
  def known_recipe_fixture(attrs \\ %{}) do
    {:ok, known_recipe} =
      attrs
      |> Enum.into(%{
        components: [],
        description: "some description",
        name: "some name",
        price: 42
      })
      |> Pots.Model.create_known_recipe()

    known_recipe
  end

  @doc """
  Generate a owned_books.
  """
  def owned_books_fixture(attrs \\ %{}) do
    {:ok, owned_books} =
      attrs
      |> Enum.into(%{})
      |> Pots.Model.create_owned_books()

    owned_books
  end
end
