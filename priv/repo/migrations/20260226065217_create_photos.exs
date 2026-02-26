defmodule DynamicEnvision.Repo.Migrations.CreatePhotos do
  use Ecto.Migration

  def change do
    create table(:photos) do
      add :url, :string, null: false
      add :filename, :string, null: false
      add :category, :string, null: false, default: "general"
      add :featured, :boolean, null: false, default: false
      add :position, :integer, null: false, default: 0

      timestamps(type: :utc_datetime)
    end

    create index(:photos, [:featured])
    create index(:photos, [:category])
  end
end
