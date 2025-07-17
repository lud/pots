defmodule PotsWeb.LaboratoryController do
  use PotsWeb, :controller

  def index(conn, _params) do
    conn
    |> assign_prop(:text, "Hello world")
    |> render_inertia("Laboratory")
  end
end
