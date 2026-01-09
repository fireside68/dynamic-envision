defmodule DynamicEnvision.Photos.FileSystem.Local do
  @moduledoc """
  Local filesystem implementation of FileSystemBehaviour.

  This module provides real file system operations for production use.
  It implements the `DynamicEnvision.Photos.FileSystemBehaviour` contract.

  ## Usage

      iex> DynamicEnvision.Photos.FileSystem.Local.list_images("/path/to/images")
      {:ok, ["/path/to/images/img1.jpg", "/path/to/images/img2.png"]}

      iex> DynamicEnvision.Photos.FileSystem.Local.file_exists?("/path/to/image.jpg")
      true

      iex> DynamicEnvision.Photos.FileSystem.Local.basename("/path/to/image.jpg")
      "image.jpg"

  """

  @behaviour DynamicEnvision.Photos.FileSystemBehaviour

  @image_extensions ~w(.jpg .jpeg .png .gif .webp)

  @impl true
  def list_images(path) do
    case File.ls(path) do
      {:ok, files} ->
        images =
          files
          |> Enum.filter(&image_file?/1)
          |> Enum.map(&Path.join(path, &1))
          |> Enum.sort()

        {:ok, images}

      {:error, reason} ->
        {:error, reason}
    end
  end

  @impl true
  def file_exists?(path) do
    File.exists?(path)
  end

  @impl true
  def basename(path) do
    Path.basename(path)
  end

  # Private Functions

  defp image_file?(filename) do
    extension =
      filename
      |> Path.extname()
      |> String.downcase()

    extension in @image_extensions
  end
end
