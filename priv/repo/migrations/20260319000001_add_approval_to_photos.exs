defmodule DynamicEnvision.Repo.Migrations.AddApprovalToPhotos do
  use Ecto.Migration

  def change do
    alter table(:photos) do
      add :approved, :boolean, default: false, null: false
      add :uploaded_by_id, references(:contractors, on_delete: :nilify_all)
    end

    # All existing photos are already on the site — mark them approved
    execute "UPDATE photos SET approved = true", "UPDATE photos SET approved = false"
  end
end
