defmodule DynamicEnvisionWeb.Plugs.RequireAdmin do
  @moduledoc """
  Plug that allows access only to contractors with an admin-level role
  (owner or office). Redirects others to /portal.
  """

  import Plug.Conn
  import Phoenix.Controller

  alias DynamicEnvision.Contractors.Contractor

  def init(opts), do: opts

  def call(%{assigns: %{current_contractor: contractor}} = conn, _opts) do
    if Contractor.admin?(contractor) do
      conn
    else
      conn
      |> put_flash(:error, "You do not have permission to access this page.")
      |> redirect(to: "/portal")
      |> halt()
    end
  end

  def call(conn, _opts) do
    conn
    |> put_flash(:error, "You do not have permission to access this page.")
    |> redirect(to: "/portal")
    |> halt()
  end
end
