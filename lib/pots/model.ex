defmodule Pots.Model do
  alias Pots.Data
  alias Pots.Repo
  alias Pots.Model.KnownRecipe
  alias Pots.Model.Wealth
  alias Pots.Model.IngredientStock
  import Ecto.Query, warn: false

  @moduledoc false

  def fetch_wealth!() do
    Repo.one!(
      from(w in Wealth, where: w.currency == ^Wealth.default_currency(), select: w.amount)
    )
  end

  def update_wealth!(increment) do
    {:ok, new_amount} =
      Repo.transaction(fn ->
        wealth = Repo.one!(from(w in Wealth, where: w.currency == ^Wealth.default_currency()))
        new_wealth = Wealth.changeset(wealth, %{amount: wealth.amount + increment})
        Repo.update!(new_wealth).amount
      end)

    new_amount
  end

  def fetch_ingredient_stock!(id) do
    case Repo.get(IngredientStock, id) do
      nil -> 0
      stock -> stock.amount
    end
  end

  def list_ingredient_stock() do
    stocks = Repo.all(IngredientStock)

    # Convert list of stocks to a map with id as key and amount as value
    Enum.into(stocks, %{}, fn %{id: id, amount: amount} -> {id, amount} end)
  end

  def create_ingredient_stock(attrs) do
    %IngredientStock{}
    |> IngredientStock.changeset(attrs)
    |> Repo.insert()
  end

  def update_ingredient_stock!(id, increment) do
    {:ok, new_amount} =
      Repo.transaction(fn ->
        case Repo.get(IngredientStock, id) do
          nil ->
            %IngredientStock{id: id}
            |> IngredientStock.changeset(%{amount: increment})
            |> Repo.insert!()
            |> Map.fetch!(:amount)

          stock ->
            %IngredientStock{id: id}
            |> IngredientStock.changeset(%{amount: stock.amount + increment})
            |> Repo.update!()
            |> Map.fetch!(:amount)
        end
      end)

    new_amount
  end

  def buy_ingredient(id, amount) when amount > 0 do
    Repo.transact(fn ->
      with {:ok, %{price: price}} <- Data.Ingredients.fetch(id),
           :ok <- check_affordable(price, amount) do
        new_wealth = update_wealth!(-price * amount)
        new_amount = update_ingredient_stock!(id, amount)
        {:ok, {new_wealth, new_amount}}
      end
    end)
  end

  defp check_affordable(price, amount) do
    true = Repo.in_transaction?()

    if fetch_wealth!() >= price * amount do
      :ok
    else
      {:error, :not_enough_wealth}
    end
  end

  def buy_book(id) do
    Repo.transact(fn ->
      with {:ok, %{price: price, recipes: recipes}} <- Data.Books.fetch(id),
           :ok <- check_affordable(price, 1) do
        new_wealth = update_wealth!(-price)

        # Add all recipes from the book to known recipes
        added_recipes =
          Enum.map(recipes, fn recipe ->
            {:ok, known_recipe} = create_known_recipe(recipe)
            known_recipe
          end)

        {:ok, {new_wealth, added_recipes}}
      end
    end)
  end

  def list_recipes do
    Repo.all(KnownRecipe)
  end

  def fetch_known_recipe!(id), do: Repo.get!(KnownRecipe, id)

  def create_known_recipe(attrs) do
    %KnownRecipe{}
    |> KnownRecipe.changeset(attrs)
    |> Repo.insert()
  end
end
