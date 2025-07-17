defmodule PotsWeb.LaboratoryControllerTest do
  import Inertia.Testing
  use PotsWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, ~p"/laboratory")
    assert "Laboratory" = inertia_component(conn)
    # assert %{text: "Hello world"} = inertia_props(conn)
  end
end
