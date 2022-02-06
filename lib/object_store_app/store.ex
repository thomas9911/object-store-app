defmodule ObjectStoreApp.Store do
  @expiry_time_in_seconds 3600

  def list_objects(username) do
    response =
      username
      |> ExAws.S3.list_objects()
      |> ExAws.request()

    case response do
      {:ok, %{body: body}} ->
        {:ok, Enum.map(body.contents, & &1.key)}

      e ->
        e
    end
  end

  def create_bucket(username) do
    username
    |> ExAws.S3.put_bucket("default")
    |> ExAws.request()
  end

  def delete_bucket(username) do
    case username
         |> ExAws.S3.delete_bucket()
         |> ExAws.request() do
      {:ok, data} ->
        {:ok, data}

      {:error, {:http_error, 404, _}} ->
        {:ok, nil}

      e ->
        e
    end
  end

  # def list_users do
  #   # [version: "2011-06-15"]
  #   []
  #   |> ExAws.Iam.list_users()
  #   |> ExAws.request()
  # end

  def upload_signed_url(username, filename) do
    :s3
    |> ExAws.Config.new()
    |> ExAws.S3.presigned_url(:put, username, filename, expires_in: @expiry_time_in_seconds)
  end

  def download_signed_url(username, filename) do
    :s3
    |> ExAws.Config.new()
    |> ExAws.S3.presigned_url(:get, username, filename, expires_in: @expiry_time_in_seconds)
  end
end

# curl -v -F filename=README.md -F upload=@README.md http://localhost:9000/test/file?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=nRxhyuGuk3DJPSl7JRTPKd5i75lgCGhpLgFpDW97mK2wMqXc2DntN%2BArbLekTCpX%2F20220129%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20220129T213530Z&X-Amz-Expires=60&X-Amz-SignedHeaders=host&X-Amz-Signature=9d028d38ef4f99c598c66657344e8dc7ddd92d1f8aaf9917afff5403769fbcc4

# Invoke-WebRequest -inFile='README.md' 'http://localhost:9000/test/file?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=nRxhyuGuk3DJPSl7JRTPKd5i75lgCGhpLgFpDW97mK2wMqXc2DntN%2BArbLekTCpX%2F20220129%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20220129T213530Z&X-Amz-Expires=60&X-Amz-SignedHeaders=host&X-Amz-Signature=9d028d38ef4f99c598c66657344e8dc7ddd92d1f8aaf9917afff5403769fbcc4'
