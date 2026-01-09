defmodule DynamicEnvision.Photos.FileSystemBehaviour do
  @moduledoc """
  Behaviour for file system operations.

  This behaviour defines the contract for file system operations used by the
  PhotoShuffle module. By using a behaviour, we can mock file operations in
  tests using Mox.

  ## Implementation

  The default implementation is `DynamicEnvision.Photos.FileSystem.Local` which
  uses actual file system operations. In tests, you can use a mock implementation
  via Mox.

  ## Example

      # In production code
      defmodule MyModule do
        @file_system Application.compile_env(:dynamic_envision, :file_system)

        def list_images(path) do
          @file_system.list_images(path)
        end
      end

      # In test
      Mox.expect(FileSystemMock, :list_images, fn _path ->
        {:ok, ["image1.jpg", "image2.jpg"]}
      end)

  """

  @doc """
  Lists all image files in the given directory.

  Returns `{:ok, [String.t()]}` with a list of image file paths,
  or `{:error, term()}` if the operation fails.

  ## Parameters

    * `path` - The directory path to scan for images

  ## Returns

    * `{:ok, list}` - List of image file paths
    * `{:error, reason}` - Error tuple with reason

  """
  @callback list_images(path :: String.t()) ::
              {:ok, [String.t()]} | {:error, term()}

  @doc """
  Checks if a file exists at the given path.

  ## Parameters

    * `path` - The file path to check

  ## Returns

    * `true` if the file exists
    * `false` if the file does not exist

  """
  @callback file_exists?(path :: String.t()) :: boolean()

  @doc """
  Gets the base name of a file from a path.

  ## Parameters

    * `path` - The file path

  ## Returns

    * The base name of the file (e.g., "IMG_5366.jpg" from "/path/to/IMG_5366.jpg")

  """
  @callback basename(path :: String.t()) :: String.t()
end
