ExUnit.start()
Ecto.Adapters.SQL.Sandbox.mode(DynamicEnvision.Repo, :manual)

# Start Wallaby
{:ok, _} = Application.ensure_all_started(:wallaby)
Application.put_env(:wallaby, :base_url, DynamicEnvisionWeb.Endpoint.url())
