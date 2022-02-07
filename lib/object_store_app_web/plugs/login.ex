defmodule ObjectStoreAppWeb.Plugs.Login do
  import Plug.Conn
  import Phoenix.Controller

  def init(options) do
    options
  end

  def call(conn, _opts) do
    conn =
      conn
      |> fetch_session()

    conn
    |> login(get_session(conn, "logged_in"))
  end

  def login(conn, nil) do
    url = current_url(conn, %{})

    conn
    |> redirect(to: "/login?url=#{url}")
    |> halt()
  end

  def login(conn, token) when is_map(token) do
    IO.inspect(token, label: "logged in")

    conn
  end

  def set_login(conn, user) do
    put_session(conn, "logged_in", %{username: user.username, id: user.id})
  end

  def pop_login(conn) do
    delete_session(conn, "logged_in")
  end
end
