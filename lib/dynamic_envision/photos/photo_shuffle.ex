defmodule DynamicEnvision.Photos.PhotoShuffle do
  @moduledoc """
  A reusable module for managing and shuffling image collections with intelligent metadata generation.

  PhotoShuffle provides functionality for:
  - Processing images from directories
  - Randomly selecting images from collections
  - Generating smart titles from filenames
  - Assigning deterministic locations via hashing
  - Managing image metadata

  This module can be extracted as a standalone Hex package for use in other projects.

  ## Usage

      # Process images from a directory
      {:ok, images} = PhotoShuffle.process_images("/path/to/images", "Windows")

      # Shuffle and select 6 random images
      selected = PhotoShuffle.shuffle_images(images, 6)

      # Generate a title from a filename
      title = PhotoShuffle.generate_title("IMG_5366.jpg")
      # => "Professional Window Installation"

      # Get deterministic location for an image
      location = PhotoShuffle.smart_location("/path/to/IMG_5366.jpg", "Windows")
      # => "Denver"

  ## Configuration

  Configure the file system implementation in your config:

      # config/config.exs
      config :dynamic_envision,
        file_system: DynamicEnvision.Photos.FileSystem.Local

      # config/test.exs
      config :dynamic_envision,
        file_system: DynamicEnvision.Photos.FileSystemMock

  """

  alias DynamicEnvision.Photos.Image

  @file_system Application.compile_env(
                 :dynamic_envision,
                 :file_system,
                 DynamicEnvision.Photos.FileSystem.Local
               )

  # Colorado locations for the Denver metro area service coverage
  @locations [
    "Denver",
    "Aurora",
    "Boulder",
    "Fort Collins",
    "Colorado Springs",
    "Adams County",
    "Arvada",
    "Broomfield",
    "Lakewood",
    "Arvada",
    "Westminster",
    "Thornton",
    "Centennial",
    "Longmont",
    "Cheyenne"
  ]

  @doc """
  Processes images from a directory and returns a list of Image structs.

  Scans the given directory for image files, generates metadata for each,
  and returns a list of Image structs ready for display.

  ## Parameters

    * `path` - The directory path to scan for images
    * `category` - The category to assign to all images (e.g., "Windows", "Exterior")
    * `opts` - Optional keyword list:
      * `:base_url` - Base URL for image src (default: "/images")

  ## Returns

    * `{:ok, [%Image{}]}` - List of Image structs
    * `{:error, reason}` - Error tuple if directory cannot be read

  ## Examples

      iex> PhotoShuffle.process_images("/priv/static/images/windows", "Windows")
      {:ok, [
        %Image{
          src: "/images/windows/IMG_5366.jpg",
          title: "Professional Window Installation",
          category: "Windows",
          location: "Denver",
          original_path: "/priv/static/images/windows/IMG_5366.jpg"
        },
        # ...
      ]}

  """
  @spec process_images(String.t(), String.t(), keyword()) ::
          {:ok, [Image.t()]} | {:error, term()}
  def process_images(path, category, opts \\ []) do
    base_url = Keyword.get(opts, :base_url, "/design/pictures")

    case @file_system.list_images(path) do
      {:ok, image_paths} ->
        images =
          image_paths
          |> Enum.map(fn image_path ->
            filename = @file_system.basename(image_path)
            title = generate_title(filename)
            location = smart_location(image_path, category)

            # Build the web-accessible URL
            src = build_image_url(image_path, base_url)

            Image.new(src, title, category,
              location: location,
              original_path: image_path
            )
          end)

        {:ok, images}

      {:error, reason} ->
        {:error, reason}
    end
  end

  @doc """
  Randomly shuffles a collection of images and selects N items.

  Uses a random sort to shuffle the images, then selects up to `count` items.
  If the collection has fewer than `count` items, returns all items shuffled.

  ## Parameters

    * `images` - List of Image structs to shuffle
    * `count` - Number of images to select (default: 6)

  ## Returns

    * List of shuffled Image structs, up to `count` items

  ## Examples

      iex> images = [%Image{}, %Image{}, %Image{}]
      iex> selected = PhotoShuffle.shuffle_images(images, 2)
      iex> length(selected)
      2

      iex> PhotoShuffle.shuffle_images([], 6)
      []

  """
  @spec shuffle_images([Image.t()], non_neg_integer()) :: [Image.t()]
  def shuffle_images(images, count \\ 6)
  def shuffle_images([], _count), do: []

  def shuffle_images(images, count) when is_list(images) and is_integer(count) and count >= 0 do
    images
    |> Enum.shuffle()
    |> Enum.take(min(count, length(images)))
  end

  @doc """
  Generates a human-readable title from an image filename.

  Converts filenames like "IMG_5366.jpg" or "window-installation-denver.jpg"
  into readable titles. Handles various naming conventions:
  - IMG_XXXX patterns → "Professional [Category] Installation"
  - Descriptive filenames → Titlecased words
  - Numeric filenames → Generic project title

  ## Parameters

    * `filename` - The image filename (with or without extension)

  ## Returns

    * A human-readable title string

  ## Examples

      iex> PhotoShuffle.generate_title("IMG_5366.jpg")
      "Professional Window Installation"

      iex> PhotoShuffle.generate_title("beautiful-door-entry.jpg")
      "Beautiful Door Entry"

      iex> PhotoShuffle.generate_title("12345.png")
      "Project Showcase"

  """
  @spec generate_title(String.t()) :: String.t()
  def generate_title(filename) do
    name =
      filename
      |> Path.rootname()
      |> String.replace(~r/[_-]/, " ")
      |> String.trim()

    cond do
      # IMG_XXXX pattern
      String.match?(name, ~r/^IMG\s+\d+$/i) ->
        "Professional Installation Project"

      # Purely numeric
      String.match?(name, ~r/^\d+$/) ->
        "Project Showcase"

      # Descriptive filename
      String.length(name) > 0 ->
        name
        |> String.split()
        |> Enum.map(&String.capitalize/1)
        |> Enum.join(" ")

      # Fallback
      true ->
        "Portfolio Project"
    end
  end

  @doc """
  Assigns a deterministic location to an image based on its path.

  Uses a hash function to consistently map image paths to locations in the
  Denver metro service area. The same image path will always receive the same
  location, ensuring consistency across page loads.

  ## Parameters

    * `path` - The image path (used for hashing)
    * `_category` - The image category (reserved for future use)

  ## Returns

    * A location string from the service area

  ## Examples

      iex> PhotoShuffle.smart_location("/path/to/IMG_5366.jpg", "Windows")
      "Denver"  # Always returns the same location for this path

      iex> PhotoShuffle.smart_location("/path/to/IMG_8427.jpg", "Windows")
      "Boulder"  # Different path, different location

  """
  @spec smart_location(String.t(), String.t()) :: String.t()
  def smart_location(path, _category) do
    # Hash the path to get a deterministic index
    hash = hash_path(path)
    index = rem(hash, length(@locations))

    Enum.at(@locations, index)
  end

  @doc """
  Returns the list of all available locations.

  ## Examples

      iex> PhotoShuffle.locations()
      ["Denver", "Aurora", "Boulder", ...]

  """
  @spec locations() :: [String.t()]
  def locations, do: @locations

  # Private Functions

  @doc false
  @spec hash_path(String.t()) :: non_neg_integer()
  def hash_path(path) do
    # Create a simple but consistent hash from the path
    path
    |> String.to_charlist()
    |> Enum.reduce(0, fn char, acc -> acc + char end)
    |> abs()
  end

  defp build_image_url(image_path, base_url) do
    # Extract the relevant part of the path for the URL
    # e.g., "/priv/static/images/windows/IMG_5366.jpg" → "/images/windows/IMG_5366.jpg"
    case String.split(image_path, "priv/static/", parts: 2) do
      [_prefix, suffix] ->
        Path.join(base_url, suffix)

      _ ->
        # Fallback: just use the basename
        filename = Path.basename(image_path)
        Path.join(base_url, filename)
    end
  end
end
