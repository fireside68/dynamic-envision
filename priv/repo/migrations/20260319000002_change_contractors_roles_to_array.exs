defmodule DynamicEnvision.Repo.Migrations.ChangeContractorsRolesToArray do
  use Ecto.Migration

  def up do
    # Drop the string CHECK constraint on contractors
    drop constraint(:contractors, :valid_role)

    # Rename role → roles and change to text[] on contractors
    execute "ALTER TABLE contractors RENAME COLUMN role TO roles"
    execute "ALTER TABLE contractors ALTER COLUMN roles DROP DEFAULT"
    execute "ALTER TABLE contractors ALTER COLUMN roles TYPE text[] USING ARRAY[roles]::text[]"
    execute "ALTER TABLE contractors ALTER COLUMN roles SET DEFAULT ARRAY['contractor']"

    # Rename role → roles and change to text[] on invitations
    execute "ALTER TABLE invitations RENAME COLUMN role TO roles"
    execute "ALTER TABLE invitations ALTER COLUMN roles DROP DEFAULT"
    execute "ALTER TABLE invitations ALTER COLUMN roles TYPE text[] USING ARRAY[roles]::text[]"
    execute "ALTER TABLE invitations ALTER COLUMN roles SET DEFAULT ARRAY['contractor']"
  end

  def down do
    execute "ALTER TABLE contractors ALTER COLUMN roles TYPE text USING roles[1]"
    execute "ALTER TABLE contractors ALTER COLUMN roles SET DEFAULT 'contractor'"
    execute "ALTER TABLE contractors RENAME COLUMN roles TO role"
    create constraint(:contractors, :valid_role, check: "role IN ('contractor', 'owner')")

    execute "ALTER TABLE invitations ALTER COLUMN roles TYPE text USING roles[1]"
    execute "ALTER TABLE invitations ALTER COLUMN roles SET DEFAULT 'contractor'"
    execute "ALTER TABLE invitations RENAME COLUMN roles TO role"
  end
end
