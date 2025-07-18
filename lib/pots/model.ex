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
        Repo.update!(new_wealth).amount |> dbg()
      end)

    new_amount
  end

  def buy_ingredient(id, amount) do
    Repo.transact(fn ->
      with {:ok, %{price: price}} <- Data.Ingredients.fetch(id),
           :ok <- check_affordable(price, amount) do
        {:ok, update_wealth!(-price * amount)}
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
end
