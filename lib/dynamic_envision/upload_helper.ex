defmodule DynamicEnvision.UploadHelper do
  @moduledoc """
  Generates presigned URLs for direct browser-to-Tigris uploads using ExAws.
  """

  @bucket_env_key "S3_BUCKET_NAME"
  @default_bucket "dynamic-bucket"
  @expires_in 3600

  @doc """
  Generates a presigned PUT URL for a new photo upload.

  Returns `{:ok, %{url: url, key: key}}` or `{:error, reason}`.
  The `entry` argument is a `Phoenix.LiveView.UploadEntry` struct.
  """
  def presign_upload(entry) do
    bucket = System.get_env(@bucket_env_key, @default_bucket)
    key = "photos/#{Ecto.UUID.generate()}-#{sanitize_filename(entry.client_name)}"
    config = ExAws.Config.new(:s3)

    case ExAws.S3.presigned_url(config, :put, bucket, key, expires_in: @expires_in) do
      {:ok, url} -> {:ok, %{url: url, key: key}}
      {:error, reason} -> {:error, reason}
    end
  end

  @doc """
  Builds the public URL for a stored object given its S3 key.
  """
  def public_url(key) do
    bucket = System.get_env(@bucket_env_key, @default_bucket)
    host = Application.get_env(:ex_aws, :s3, []) |> Keyword.get(:host, "fly.storage.tigris.dev")
    "https://#{bucket}.#{host}/#{key}"
  end

  # Strips path components and replaces non-safe characters with underscores.
  defp sanitize_filename(filename) do
    filename
    |> Path.basename()
    |> String.replace(~r/[^\w.\-]/, "_")
  end
end
