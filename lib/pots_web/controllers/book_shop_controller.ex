defmodule PotsWeb.BookShopController do
  alias Pots.Model
  alias Pots.Data
  use PotsWeb, :controller

  def index(conn, _params) do
    conn
    |> assign_prop(:books, Data.Books.list())
    |> assign_prop(:known_recipes, Model.list_recipes())
    |> assign_prop(:wealth, Model.fetch_wealth!())
    |> render_inertia("BookShop")
  end

  def buy(conn, params) do
    %{"id" => id} = params

    conn =
      case Model.buy_book(id) do
        {:ok, {_new_wealth, _added_recipes}} -> conn
        {:error, :not_enough_wealth} -> assign_errors(conn, %{message: "Not enough wealth!"})
        {:error, :not_found} -> assign_errors(conn, %{message: "Book not found!"})
      end

    redirect(conn, to: "/bookshop")
  end
end
