defmodule DynamicEnvisionWeb.AuthController do
  use DynamicEnvisionWeb, :controller

  plug Ueberauth

  alias DynamicEnvision.Contractors
  alias DynamicEnvision.Contractors.Contractor

  def callback(%{assigns: %{ueberauth_auth: auth}} = conn, _params) do
    email = auth.info.email
    google_uid = auth.uid

    case Contractors.get_contractor_by_email(email) do
      {:ok, contractor} ->
        {:ok, contractor} = Contractors.link_google_uid(contractor, google_uid)

        conn
        |> put_session(:contractor_id, contractor.id)
        |> redirect(to: landing_path(contractor))

      {:error, :not_found} ->
        case Contractors.find_or_create_from_invitation(email, google_uid) do
          {:ok, contractor} ->
            conn
            |> put_session(:contractor_id, contractor.id)
            |> redirect(to: landing_path(contractor))

          {:error, _reason} ->
            conn
            |> put_flash(:error, "Access restricted to invited users.")
            |> redirect(to: ~p"/")
        end
    end
  end

  def callback(%{assigns: %{ueberauth_failure: _failure}} = conn, _params) do
    failure(conn, %{})
  end

  def failure(conn, _params) do
    conn
    |> put_flash(:error, "Authentication failed.")
    |> redirect(to: ~p"/")
  end

  defp landing_path(%Contractor{} = contractor) do
    if Contractor.admin?(contractor), do: ~p"/admin", else: ~p"/portal"
  end

  def logout(conn, _params) do
    conn
    |> clear_session()
    |> redirect(to: ~p"/")
  end
end
