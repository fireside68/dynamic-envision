defmodule DynamicEnvision.Photos.Photo do
  use Ecto.Schema
  import Ecto.Changeset

  schema "photos" do
    field :url, :string
    field :filename, :string
    field :category, :string
    field :featured, :boolean, default: false
    field :position, :integer, default: 0
    field :approved, :boolean, default: false
    # website_status: "pending" | "queued" | "published" | "archived"
    field :website_status, :string, default: "pending"
    field :delivery_flagged, :boolean, default: false
    field :job_ref, :string
    belongs_to :uploaded_by, DynamicEnvision.Contractors.Contractor, foreign_key: :uploaded_by_id

    timestamps(type: :utc_datetime)
  end

  @valid_categories ~w(windows exterior doors general)

  @doc false
  def changeset(photo, attrs) do
    photo
    |> cast(attrs, [:url, :filename, :category, :featured, :position, :approved, :uploaded_by_id,
                    :website_status, :delivery_flagged, :job_ref])
    |> validate_required([:url, :filename, :category])
    |> validate_inclusion(:category, @valid_categories)
    |> validate_inclusion(:website_status, ~w(pending queued published archived))
    |> validate_number(:position, greater_than_or_equal_to: 0)
  end
end
