defmodule ObjectStoreAppWeb.PageControllerTest do
  use ObjectStoreAppWeb.ConnCase

  test "GET / redirect to login", %{conn: conn} do
    conn = get(conn, "/")
    assert html_response(conn, 302) =~ "redirected"
  end
end
