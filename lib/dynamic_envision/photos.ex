defmodule DynamicEnvision.Photos do
  @moduledoc """
  Context for managing portfolio photos stored in Tigris S3.

  Photo website_status state machine:
    pending -> published | archived
    pending -> queued -> published | archived (optional review step)
    delivery_flagged is orthogonal — can be set in any state.
  """

  import Ecto.Query, warn: false
  alias DynamicEnvision.Repo
  alias DynamicEnvision.Photos.Photo

  # ---- Public-facing queries (published only) ----

  @doc "Featured photos for the hero slideshow — published only."
  def list_featured_photos(opts \\ []) do
    limit = Keyword.get(opts, :limit, 8)

    Photo
    |> where([p], p.featured == true and p.website_status == "published")
    |> order_by([p], asc: p.position, asc: p.inserted_at)
    |> limit(^limit)
    |> Repo.all()
  end

  @doc "Published photos for the public portfolio, optionally filtered by category."
  def list_photos(opts \\ []) do
    category = Keyword.get(opts, :category)
    limit = Keyword.get(opts, :limit, 50)

    query =
      Photo
      |> where([p], p.website_status == "published")
      |> order_by([p], asc: p.position, asc: p.inserted_at)
      |> limit(^limit)

    query = if category, do: where(query, [p], p.category == ^category), else: query

    Repo.all(query)
  end

  # ---- Admin queries ----

  @doc "All photos regardless of status, newest first."
  def list_all_photos do
    Photo
    |> order_by([p], desc: p.inserted_at)
    |> Repo.all()
  end

  @doc "Photos awaiting review (status: pending), newest first."
  def list_pending_photos do
    Photo
    |> where([p], p.website_status == "pending")
    |> order_by([p], desc: p.inserted_at)
    |> Repo.all()
  end

  @doc "Photos flagged for company delivery, newest first."
  def list_delivery_queue do
    Photo
    |> where([p], p.delivery_flagged == true)
    |> order_by([p], desc: p.inserted_at)
    |> Repo.all()
  end

  # ---- CRUD ----

  def get_photo!(id), do: Repo.get!(Photo, id)

  def create_photo(attrs \\ %{}) do
    %Photo{}
    |> Photo.changeset(attrs)
    |> Repo.insert()
  end

  def update_photo(%Photo{} = photo, attrs) do
    photo
    |> Photo.changeset(attrs)
    |> Repo.update()
  end

  def delete_photo(%Photo{} = photo), do: Repo.delete(photo)

  # ---- Status transitions ----

  @doc "Publish a photo to the public website gallery."
  def publish_photo(%Photo{} = photo) do
    update_photo(photo, %{website_status: "published", approved: true})
  end

  @doc "Queue a photo for website review (intermediate state before publishing)."
  def queue_for_website(%Photo{} = photo) do
    update_photo(photo, %{website_status: "queued"})
  end

  @doc "Archive a photo — not published, kept in storage."
  def archive_photo(%Photo{} = photo) do
    update_photo(photo, %{website_status: "archived", featured: false, approved: false})
  end

  @doc "Toggle the delivery flag on a photo."
  def set_delivery_flagged(%Photo{} = photo, flagged) when is_boolean(flagged) do
    update_photo(photo, %{delivery_flagged: flagged})
  end

  # Legacy helpers kept for backward compatibility with existing upload code
  @doc false
  def approve_photo(%Photo{} = photo), do: publish_photo(photo)

  @doc false
  def reject_photo(%Photo{} = photo), do: archive_photo(photo)

  def change_photo(%Photo{} = photo \\ %Photo{}, attrs \\ %{}) do
    Photo.changeset(photo, attrs)
  end
end
