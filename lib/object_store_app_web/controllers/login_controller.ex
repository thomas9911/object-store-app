defmodule ObjectStoreAppWeb.LoginController do
  use ObjectStoreAppWeb, :controller

  alias ObjectStoreAppWeb.Plugs.Login

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def login(conn, %{"login" => %{"password" => password, "username" => username, "url" => url}}) do
    with {:ok, args} <- parse_redirect(url),
         {:ok, redirect} <- Map.fetch(args, "url") do
      conn
      |> login_user(username, password)
      |> redirect(external: redirect)
    else
      _ ->
        conn
    end
  end

  defp login_user(conn, username, password) do
    case ObjectStoreApp.Users.login(username, password) do
      {:ok, user} ->
        conn
        |> Login.set_login(user)

      {:error, :user_not_found} ->
        conn
    end
  end

  defp parse_redirect(url) when is_binary(url) do
    case URI.parse(url).query do
      nil ->
        {:error, :invalid_redirect}

      redirect ->
        {:ok, URI.decode_query(redirect)}
    end
  end

  defp parse_redirect(_) do
    {:error, :invalid_redirect}
  end
end
