defmodule DynamicEnvision.Repo.Migrations.CreateContractorsAndInvitations do
  use Ecto.Migration

  def change do
    create table(:contractors) do
      add :email, :string, null: false
      add :name, :string, null: false
      add :google_uid, :string
      add :role, :string, null: false, default: "contractor"
      add :active, :boolean, null: false, default: true

      timestamps(type: :utc_datetime)
    end

    create unique_index(:contractors, [:email])
    create unique_index(:contractors, [:google_uid])

    create constraint(:contractors, :valid_role,
             check: "role IN ('contractor', 'owner')"
           )

    create table(:invitations) do
      add :email, :string, null: false
      add :token, :string, null: false
      add :role, :string, null: false, default: "contractor"
      add :accepted_at, :utc_datetime
      add :expires_at, :utc_datetime, null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:invitations, [:email])
    create unique_index(:invitations, [:token])
  end
end
