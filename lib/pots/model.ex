defmodule Pots.Model do
  @moduledoc false

  import Ecto.Query, warn: false
  alias Pots.Repo
  alias Pots.Model.Wealth

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
end
