defmodule PotsWeb.MarketController do
  alias Pots.Data
  use PotsWeb, :controller

  def index(conn, _params) do
    conn
    |> assign_prop(:ingredients, Data.Ingredients.list())
    |> render_inertia("Market")
  end
end
