defmodule DynamicEnvision.Repo.Migrations.AddPhotoStatusFields do
  use Ecto.Migration

  def change do
    alter table(:photos) do
      add :website_status, :string, null: false, default: "pending"
      add :delivery_flagged, :boolean, null: false, default: false
      add :job_ref, :string
    end

    # Backfill: photos that were already approved map to "published"
    execute(
      "UPDATE photos SET website_status = 'published' WHERE approved = true",
      "UPDATE photos SET website_status = 'pending'"
    )

    create index(:photos, [:website_status])
    create index(:photos, [:delivery_flagged])
  end
end
