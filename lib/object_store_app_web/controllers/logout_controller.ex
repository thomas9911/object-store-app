defmodule ObjectStoreAppWeb.LogoutController do
  use ObjectStoreAppWeb, :controller

  alias ObjectStoreAppWeb.Plugs.Login

  def logout(conn, _) do
    conn
    |> Login.pop_login()
    |> redirect(to: "/")
  end
end
