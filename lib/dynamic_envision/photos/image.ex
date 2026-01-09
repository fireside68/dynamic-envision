defmodule DynamicEnvision.Photos.Image do
  @moduledoc """
  Represents an image with its metadata.

  This struct holds all information about a portfolio image including its path,
  title, category, and location. The data is used for display in portfolio grids
  and hero slideshows.

  ## Fields

    * `:src` - The path or URL to the image file
    * `:title` - A human-readable title for the image
    * `:category` - The category this image belongs to (e.g., "Windows", "Exterior")
    * `:location` - The location where the project was completed
    * `:original_path` - The original filesystem path to the image

  ## Examples

      iex> %DynamicEnvision.Photos.Image{
      ...>   src: "/images/windows/IMG_5366.jpg",
      ...>   title: "Professional Window Installation",
      ...>   category: "Windows",
      ...>   location: "Denver",
      ...>   original_path: "/path/to/IMG_5366.jpg"
      ...> }

  """

  @enforce_keys [:src, :title, :category]
  defstruct [
    :src,
    :title,
    :category,
    :location,
    :original_path
  ]

  @type t :: %__MODULE__{
          src: String.t(),
          title: String.t(),
          category: String.t(),
          location: String.t() | nil,
          original_path: String.t() | nil
        }

  @doc """
  Creates a new Image struct.

  ## Examples

      iex> DynamicEnvision.Photos.Image.new(
      ...>   "/images/windows/IMG_5366.jpg",
      ...>   "Window Installation",
      ...>   "Windows"
      ...> )
      %DynamicEnvision.Photos.Image{
        src: "/images/windows/IMG_5366.jpg",
        title: "Window Installation",
        category: "Windows",
        location: nil,
        original_path: nil
      }

  """
  @spec new(String.t(), String.t(), String.t(), keyword()) :: t()
  def new(src, title, category, opts \\ []) do
    %__MODULE__{
      src: src,
      title: title,
      category: category,
      location: Keyword.get(opts, :location),
      original_path: Keyword.get(opts, :original_path)
    }
  end

  @doc """
  Converts an Image struct to a map suitable for JSON encoding.

  ## Examples

      iex> image = DynamicEnvision.Photos.Image.new("/images/test.jpg", "Test", "Windows")
      iex> DynamicEnvision.Photos.Image.to_map(image)
      %{
        src: "/images/test.jpg",
        title: "Test",
        category: "Windows",
        location: nil,
        original_path: nil
      }

  """
  @spec to_map(t()) :: map()
  def to_map(%__MODULE__{} = image) do
    %{
      src: image.src,
      title: image.title,
      category: image.category,
      location: image.location,
      original_path: image.original_path
    }
  end
end
