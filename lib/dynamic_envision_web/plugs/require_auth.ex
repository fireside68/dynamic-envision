defmodule DynamicEnvisionWeb.Plugs.RequireAuth do
  import Plug.Conn
  import Phoenix.Controller

  def init(opts), do: opts

  def call(conn, _opts) do
    contractor_id = get_session(conn, :contractor_id)

    case contractor_id && DynamicEnvision.Contractors.get_contractor(contractor_id) do
      {:ok, contractor} ->
        assign(conn, :current_contractor, contractor)

      _ ->
        conn
        |> put_flash(:error, "Please sign in to access the portal.")
        |> redirect(to: "/")
        |> halt()
    end
  end
end
