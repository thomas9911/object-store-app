defmodule ObjectStoreAppWeb.PageController do
  use ObjectStoreAppWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
