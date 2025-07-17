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
end
