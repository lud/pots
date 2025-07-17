defmodule PotsWeb.MarketController do
  alias Pots.Model
  alias Pots.Data
  use PotsWeb, :controller

  def index(conn, _params) do
    conn
    |> assign_prop(:ingredients, Data.Ingredients.list())
    |> assign_prop(:wealth, Model.fetch_wealth!())
    |> render_inertia("Market")
  end

  def buy(conn, params) do
    %{"amount" => amount, "id" => id, "type" => "ingredient"} = params

    conn =
      case Model.buy_ingredient(id, amount) do
        {:ok, _} ->
          conn

        {:error, :not_enough_wealth} ->
          conn
          |> assign_errors(%{message: "not enough wealth"})
      end

    redirect(conn, to: "/market")
  end
end
