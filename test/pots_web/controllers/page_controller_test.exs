defmodule PotsWeb.PageControllerTest do
  import Inertia.Testing
  use PotsWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, ~p"/")
    assert "Laboratory" = inertia_component(conn)
    assert %{text: "Hello world"} = inertia_props(conn)
  end
end
