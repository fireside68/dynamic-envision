import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :dynamic_envision, DynamicEnvision.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "dynamic_envision_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: System.schedulers_online() * 2

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :dynamic_envision, DynamicEnvisionWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "test_secret_key_base_at_least_64_bytes_long_for_security_purposes_test",
  server: true

# Configure Wallaby
config :wallaby,
  otp_app: :dynamic_envision,
  driver: Wallaby.Chrome,
  screenshot_on_failure: true,
  hackney_options: [timeout: :infinity, recv_timeout: :infinity]

# In test we don't send emails.
config :dynamic_envision, DynamicEnvision.Mailer, adapter: Swoosh.Adapters.Test

# Disable swoosh api client as it is only required for production adapters.
config :swoosh, :api_client, false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

# Enable helpful, but potentially expensive runtime checks
config :phoenix_live_view,
  enable_expensive_runtime_checks: true

# Configure PhotoShuffle to use mock file system in tests
config :dynamic_envision,
  file_system: DynamicEnvision.Photos.FileSystemMock
