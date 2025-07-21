defmodule PotsWeb.MarketController do
  alias Pots.Data
  alias Pots.Model
  use PotsWeb, :controller

  def index(conn, _params) do
    conn
    |> assign_prop(:ingredients, &Data.Ingredients.list/0)
    |> assign_prop(:inventory_ingredients, &Model.list_ingredient_stock/0)
    |> assign_prop(:wealth, &Model.fetch_wealth!/0)
    |> render_inertia("Market")
  end

  def buy(conn, params) do
    %{"amount" => amount, "id" => id, "type" => "ingredient"} = params

    conn =
      case Model.buy_ingredient(id, amount) do
        {:ok, _} -> conn
        {:error, :not_enough_wealth} -> assign_errors(conn, %{message: "Not enough wealth!"})
      end

    redirect(conn, to: "/market")
  end
end
