defmodule DynamicEnvision.Repo.Migrations.CreateShifts do
  use Ecto.Migration

  def change do
    create table(:shifts) do
      add :contractor_id, references(:contractors, on_delete: :restrict), null: false
      add :clocked_in_at, :utc_datetime, null: false
      add :clocked_out_at, :utc_datetime
      add :note, :text

      timestamps(type: :utc_datetime)
    end

    create index(:shifts, [:contractor_id])
    create index(:shifts, [:contractor_id, :clocked_in_at])
    create index(:shifts, [:clocked_out_at])
  end
end
