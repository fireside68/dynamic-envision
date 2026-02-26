defmodule DynamicEnvision.Photos.Photo do
  use Ecto.Schema
  import Ecto.Changeset

  schema "photos" do
    field :url, :string
    field :filename, :string
    field :category, :string
    field :featured, :boolean, default: false
    field :position, :integer, default: 0

    timestamps(type: :utc_datetime)
  end

  @valid_categories ~w(windows exterior doors general)

  @doc false
  def changeset(photo, attrs) do
    photo
    |> cast(attrs, [:url, :filename, :category, :featured, :position])
    |> validate_required([:url, :filename, :category])
    |> validate_inclusion(:category, @valid_categories)
    |> validate_number(:position, greater_than_or_equal_to: 0)
  end
end
