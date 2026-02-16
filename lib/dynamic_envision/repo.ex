defmodule DynamicEnvision.Repo do
  use Ecto.Repo,
    otp_app: :dynamic_envision,
    adapter: Ecto.Adapters.Postgres
end
