defmodule DynamicEnvisionWeb.Plugs.RequireOwner do
  import Plug.Conn
  import Phoenix.Controller

  def init(opts), do: opts

  def call(%{assigns: %{current_contractor: %{role: "owner"}}} = conn, _opts), do: conn

  def call(conn, _opts) do
    conn
    |> put_flash(:error, "You do not have permission to access this page.")
    |> redirect(to: "/portal")
    |> halt()
  end
end
