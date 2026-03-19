# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     DynamicEnvision.Repo.insert!(%DynamicEnvision.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

# Seed contractor accounts — run with: mix run priv/repo/seeds.exs
contractors = [
  %{email: "cjohns0913@gmail.com", name: "Your Name", roles: ["owner"], active: true},
  %{
    email: "cedric.johnson@wolfpackcontractor.services",
    name: "Cedric Johnson",
    roles: ["contractor", "office"],
    active: true
  }
]

Enum.each(contractors, fn attrs ->
  case DynamicEnvision.Contractors.get_contractor_by_email(attrs.email) do
    {:ok, existing} ->
      existing
      |> DynamicEnvision.Contractors.Contractor.changeset(%{roles: attrs.roles})
      |> DynamicEnvision.Repo.update!()

      IO.puts("Updated roles for: #{attrs.email}")

    {:error, :not_found} ->
      %DynamicEnvision.Contractors.Contractor{}
      |> DynamicEnvision.Contractors.Contractor.changeset(attrs)
      |> DynamicEnvision.Repo.insert!()

      IO.puts("Seeded contractor: #{attrs.email}")
  end
end)
