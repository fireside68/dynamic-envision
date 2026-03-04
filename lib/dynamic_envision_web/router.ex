defmodule DynamicEnvisionWeb.Router do
  use DynamicEnvisionWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {DynamicEnvisionWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :admin_auth do
    plug :basic_auth
  end

  scope "/", DynamicEnvisionWeb do
    pipe_through :browser

    live "/", HomeLive.Index, :index
  end

  scope "/admin", DynamicEnvisionWeb.Admin do
    pipe_through [:browser, :admin_auth]

    live "/portfolio", PortfolioLive, :index
  end

  # Other scopes may use custom stacks.
  # scope "/api", DynamicEnvisionWeb do
  #   pipe_through :api
  # end

  defp basic_auth(conn, _opts) do
    valid = [
      {System.get_env("ADMIN_USER_1"), System.get_env("ADMIN_PASS_1")},
      {System.get_env("ADMIN_USER_2"), System.get_env("ADMIN_PASS_2")}
    ]

    with {user, pass} <- Plug.BasicAuth.parse_basic_auth(conn),
         true <- Enum.any?(valid, fn {u, p} -> u == user && p == pass end) do
      conn
    else
      _ -> conn |> Plug.BasicAuth.request_basic_auth(realm: "Admin") |> halt()
    end
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:dynamic_envision, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: DynamicEnvisionWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
