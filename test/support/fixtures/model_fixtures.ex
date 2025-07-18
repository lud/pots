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
end
