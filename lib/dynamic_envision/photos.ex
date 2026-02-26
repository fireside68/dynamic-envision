defmodule DynamicEnvision.Photos do
  @moduledoc """
  Context for managing portfolio photos stored in Tigris S3.
  """

  import Ecto.Query, warn: false
  alias DynamicEnvision.Repo
  alias DynamicEnvision.Photos.Photo

  @doc """
  Returns featured photos for the hero slideshow, ordered by position then insertion time.
  """
  def list_featured_photos(opts \\ []) do
    limit = Keyword.get(opts, :limit, 8)

    Photo
    |> where([p], p.featured == true)
    |> order_by([p], asc: p.position, asc: p.inserted_at)
    |> limit(^limit)
    |> Repo.all()
  end

  @doc """
  Returns all photos for the portfolio, optionally filtered by category.
  """
  def list_photos(opts \\ []) do
    category = Keyword.get(opts, :category)
    limit = Keyword.get(opts, :limit, 50)

    query =
      Photo
      |> order_by([p], asc: p.position, asc: p.inserted_at)
      |> limit(^limit)

    query =
      if category do
        where(query, [p], p.category == ^category)
      else
        query
      end

    Repo.all(query)
  end

  @doc """
  Gets a single photo. Raises `Ecto.NoResultsError` if not found.
  """
  def get_photo!(id), do: Repo.get!(Photo, id)

  @doc """
  Creates a photo record after a successful S3 upload.
  """
  def create_photo(attrs \\ %{}) do
    %Photo{}
    |> Photo.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a photo's attributes.
  """
  def update_photo(%Photo{} = photo, attrs) do
    photo
    |> Photo.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a photo record. Does not delete the file from S3.
  """
  def delete_photo(%Photo{} = photo) do
    Repo.delete(photo)
  end

  @doc """
  Returns a changeset for tracking photo changes.
  """
  def change_photo(%Photo{} = photo \\ %Photo{}, attrs \\ %{}) do
    Photo.changeset(photo, attrs)
  end
end
