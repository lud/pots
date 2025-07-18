defmodule Pots.Model do
  alias Pots.Data
  alias Pots.Repo
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

  alias Pots.Model.KnownRecipe

  @doc """
  Returns the list of recipes.

  ## Examples

      iex> list_recipes()
      [%KnownRecipe{}, ...]

  """
  def list_recipes do
    Repo.all(KnownRecipe)
  end

  @doc """
  Gets a single known_recipe.

  Raises `Ecto.NoResultsError` if the Known recipe does not exist.

  ## Examples

      iex> get_known_recipe!(123)
      %KnownRecipe{}

      iex> get_known_recipe!(456)
      ** (Ecto.NoResultsError)

  """
  def get_known_recipe!(id), do: Repo.get!(KnownRecipe, id)

  @doc """
  Creates a known_recipe.

  ## Examples

      iex> create_known_recipe(%{field: value})
      {:ok, %KnownRecipe{}}

      iex> create_known_recipe(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_known_recipe(attrs) do
    %KnownRecipe{}
    |> KnownRecipe.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a known_recipe.

  ## Examples

      iex> update_known_recipe(known_recipe, %{field: new_value})
      {:ok, %KnownRecipe{}}

      iex> update_known_recipe(known_recipe, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_known_recipe(%KnownRecipe{} = known_recipe, attrs) do
    known_recipe
    |> KnownRecipe.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a known_recipe.

  ## Examples

      iex> delete_known_recipe(known_recipe)
      {:ok, %KnownRecipe{}}

      iex> delete_known_recipe(known_recipe)
      {:error, %Ecto.Changeset{}}

  """
  def delete_known_recipe(%KnownRecipe{} = known_recipe) do
    Repo.delete(known_recipe)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking known_recipe changes.

  ## Examples

      iex> change_known_recipe(known_recipe)
      %Ecto.Changeset{data: %KnownRecipe{}}

  """
  def change_known_recipe(%KnownRecipe{} = known_recipe, attrs \\ %{}) do
    KnownRecipe.changeset(known_recipe, attrs)
  end
end
