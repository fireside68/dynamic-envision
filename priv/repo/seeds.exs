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

# Seed owner accounts — run with: mix run priv/repo/seeds.exs
owners = [
  %{email: "YOUR_EMAIL@gmail.com", name: "Your Name", role: "owner", active: true}
]

Enum.each(owners, fn attrs ->
  case DynamicEnvision.Contractors.get_contractor_by_email(attrs.email) do
    {:ok, _existing} ->
      :ok

    {:error, :not_found} ->
      %DynamicEnvision.Contractors.Contractor{}
      |> DynamicEnvision.Contractors.Contractor.changeset(attrs)
      |> DynamicEnvision.Repo.insert!()

      IO.puts("Seeded owner: #{attrs.email}")
  end
end)
