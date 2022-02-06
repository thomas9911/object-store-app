defmodule ObjectStoreApp.Store.Minio do
  def login do
    with {:ok, 204, headers, _} <-
           :hackney.request(
             :post,
             path("login"),
             [{"content-type", "application/json"}],
             Jason.encode!(keys())
           ),
         {:ok, token} <- parse_login_cookie(headers) do
      {:ok, token}
    else
      e ->
        IO.inspect(e)
        :error
    end
  end

  def list_users do
    with {:ok, token} <- login(),
         {:ok, data} <- request(:get, "users", [], "", token, []) do
      {:ok, data}
    end
  end

  def get_user(access) do
    with {:ok, token} <- login(),
         {:ok, data} <- request(:get, "user?name=#{access}", [], "", token, []) do
      {:ok, data}
    end
  end

  def create_user(access, secret) do
    # create policy that limits to only current bucket

    data = %{
      "accessKey" => access,
      "secretKey" => secret,
      "groups" => [],
      "policies" => ["readwrite"]
    }

    with {:ok, token} <- login(),
         {:ok, data} <- json(:post, "users", [], data, token, []) do
      {:ok, data}
    end
  end

  def delete_user(access) do
    with {:ok, token} <- login(),
         {:ok, data} <- request(:delete, "user?name=#{access}", [], "", token, []) do
      {:ok, data}
    end
  end

  def delete_users do
    case list_users() do
      {:ok, %{"users" => nil}} ->
        []

      {:ok, %{"users" => users}} ->
        Enum.map(users, fn %{"accessKey" => access_key} ->
          delete_user(access_key)
        end)

      e ->
        e
    end
  end

  defp json(method, endpoint, headers, data, token, opts) do
    request(
      method,
      endpoint,
      headers ++ [{"content-type", "application/json"}],
      Jason.encode!(data),
      token,
      opts
    )
  end

  defp request(method, endpoint, headers, body, token, opts) do
    with {:ok, status, headers, ref} <-
           :hackney.request(
             method,
             path(endpoint),
             headers,
             body,
             opts ++ [{:cookie, [{"token", token}]}]
           ),
         {:ok, data} <- parse_json_response(status, headers, ref) do
      {:ok, data}
    else
      {:empty, 204} ->
        {:ok, nil}

      {:empty, 404} ->
        {:error, nil}

      e ->
        e
    end
  end

  defp parse_json_response(status, headers, ref) do
    with headers <- Enum.map(headers, fn {key, value} -> {String.downcase(key), value} end),
         {:header, true} <- {:header, {"content-type", "application/json"} in headers},
         {:ok, body} <- read_body(ref, ""),
         {:ok, data} <- Jason.decode(body) do
      if status in [200, 201, 204] do
        {:ok, data}
      else
        {:error, data}
      end
    else
      {:header, false} -> {:empty, status}
      e -> e
    end
  end

  defp read_body(ref, acc) do
    case :hackney.stream_body(ref) do
      {:ok, data} ->
        read_body(ref, acc <> data)

      :done ->
        {:ok, acc}

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp parse_login_cookie(headers) do
    case headers
         |> Enum.find(&(elem(&1, 0) == "Set-Cookie"))
         |> elem(1)
         |> String.split(";")
         |> Enum.map(&String.trim(&1))
         |> Enum.map(&String.split(&1, "=", parts: 2))
         |> Enum.find(fn
           ["token" | _] -> true
           _ -> false
         end) do
      ["token", token] -> {:ok, token}
      _ -> {:error, :token_not_found}
    end
  end

  defp keys do
    %{
      "accessKey" => Application.fetch_env!(:ex_aws, :access_key_id),
      "secretKey" => Application.fetch_env!(:ex_aws, :secret_access_key)
    }
  end

  defp config do
    Application.fetch_env!(:object_store_app, :minio)
  end

  defp path(endpoint) do
    "#{url()}#{endpoint}"
  end

  defp url do
    config = config()
    "#{config[:scheme]}#{config[:host]}:#{config[:port]}/api/#{config[:api_version]}/"
  end
end
