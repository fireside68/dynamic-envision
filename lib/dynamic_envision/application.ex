defmodule DynamicEnvision.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      DynamicEnvisionWeb.Telemetry,
      DynamicEnvision.Repo,
      {DNSCluster, query: Application.get_env(:dynamic_envision, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: DynamicEnvision.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: DynamicEnvision.Finch},
      # Start a worker by calling: DynamicEnvision.Worker.start_link(arg)
      # {DynamicEnvision.Worker, arg},
      # Start to serve requests, typically the last entry
      DynamicEnvisionWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: DynamicEnvision.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    DynamicEnvisionWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
