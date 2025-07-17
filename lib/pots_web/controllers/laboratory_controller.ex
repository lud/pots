defmodule PotsWeb.LaboratoryController do
  use PotsWeb, :controller

  def index(conn, _params) do
    conn
    |> render_inertia("Laboratory")
  end
end
