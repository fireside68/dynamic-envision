defmodule DynamicEnvision.Release do
  @moduledoc """
  Used for executing DB release tasks when run in production without Mix
  installed.

  Called by the Fly.io deploy hook via `/app/bin/migrate`.

  ## Fly Secrets Required

  Set these with `fly secrets set`:

    fly secrets set SECRET_KEY_BASE=$(mix phx.gen.secret)
    fly secrets set GOOGLE_CLIENT_ID=...
    fly secrets set GOOGLE_CLIENT_SECRET=...
    fly secrets set AWS_ACCESS_KEY_ID=...
    fly secrets set AWS_SECRET_ACCESS_KEY=...

  ## Seeding initial contractors

  Set `SEED_CONTRACTORS` to a JSON array of contractor objects. These are
  inserted on every deploy; existing emails are skipped (no overwrites).

    fly secrets set SEED_CONTRACTORS='[
      {"email":"cjohns0913@gmail.com","name":"Mike Johnson","roles":["owner"]},
      {"email":"cedric.johnson@wolfpackcontractor.services","name":"Cedric Johnson","roles":["contractor","office"]}
    ]'

  Valid roles: "owner", "office", "contractor"
  """

  @app :dynamic_envision

  def migrate do
    load_app()

    for repo <- repos() do
      {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :up, all: true))
    end

    seed_contractors()
  end

  def rollback(repo, version) do
    load_app()
    {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :down, to: version))
  end

  @doc """
  Reads the SEED_CONTRACTORS environment variable (JSON array) and inserts
  any contractors that do not yet exist in the database. Existing emails
  are skipped so app-side role changes are never overwritten by a re-deploy.
  """
  def seed_contractors do
    load_app()

    case System.get_env("SEED_CONTRACTORS") do
      nil ->
        IO.puts("[seed] SEED_CONTRACTORS not set — skipping.")

      json ->
        contractors = Jason.decode!(json)

        [repo] = repos()

        Ecto.Migrator.with_repo(repo, fn _repo ->
          Enum.each(contractors, fn raw ->
            attrs = %{
              email: raw["email"],
              name: raw["name"],
              roles: raw["roles"] || ["contractor"],
              active: true
            }

            result =
              %DynamicEnvision.Contractors.Contractor{}
              |> DynamicEnvision.Contractors.Contractor.changeset(attrs)
              |> DynamicEnvision.Repo.insert(on_conflict: :nothing, conflict_target: :email)

            case result do
              {:ok, %{id: nil}} ->
                IO.puts("[seed] skipped (already exists): #{attrs.email}")

              {:ok, contractor} ->
                IO.puts("[seed] inserted contractor: #{contractor.email} #{inspect(contractor.roles)}")

              {:error, changeset} ->
                IO.puts("[seed] error for #{attrs.email}: #{inspect(changeset.errors)}")
            end
          end)
        end)
    end
  end

  defp repos do
    Application.fetch_env!(@app, :ecto_repos)
  end

  defp load_app do
    Application.load(@app)
  end
end
