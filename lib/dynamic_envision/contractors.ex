defmodule DynamicEnvision.Contractors do
  import Ecto.Query

  alias DynamicEnvision.Repo
  alias DynamicEnvision.Contractors.{Contractor, Invitation}

  @doc """
  Gets a contractor by their database ID.
  Returns `{:ok, contractor}` or `{:error, :not_found}`.
  """
  def get_contractor(id) do
    case Repo.get(Contractor, id) do
      nil -> {:error, :not_found}
      contractor -> {:ok, contractor}
    end
  end

  @doc """
  Gets a contractor by email address.
  Returns `{:ok, contractor}` or `{:error, :not_found}`.
  """
  def get_contractor_by_email(email) do
    case Repo.get_by(Contractor, email: email) do
      nil -> {:error, :not_found}
      contractor -> {:ok, contractor}
    end
  end

  @doc """
  Used by OAuth callback for contractors.
  Finds a valid invitation for the email, creates the contractor, and marks the invitation accepted.
  Returns `{:ok, contractor}`, `{:error, :not_invited}`, `{:error, :invitation_expired}`,
  or `{:error, changeset}`.
  """
  def find_or_create_from_invitation(email, google_uid) do
    case Repo.get_by(Invitation, email: email) do
      nil ->
        {:error, :not_invited}

      invitation ->
        if Invitation.valid?(invitation) do
          Repo.transaction(fn ->
            contractor_attrs = %{
              email: email,
              name: email,
              google_uid: google_uid,
              roles: invitation.roles,
              active: true
            }

            case %Contractor{}
                 |> Contractor.changeset(contractor_attrs)
                 |> Repo.insert() do
              {:ok, contractor} ->
                invitation
                |> Ecto.Changeset.change(accepted_at: DateTime.utc_now() |> DateTime.truncate(:second))
                |> Repo.update!()

                contractor

              {:error, changeset} ->
                Repo.rollback({:changeset, changeset})
            end
          end)
          |> case do
            {:ok, contractor} -> {:ok, contractor}
            {:error, {:changeset, changeset}} -> {:error, changeset}
            {:error, reason} -> {:error, reason}
          end
        else
          {:error, :invitation_expired}
        end
    end
  end

  @doc """
  Updates a contractor's google_uid if it is currently nil.
  """
  def link_google_uid(%Contractor{google_uid: nil} = contractor, google_uid) do
    contractor
    |> Contractor.changeset(%{google_uid: google_uid})
    |> Repo.update()
  end

  def link_google_uid(%Contractor{} = contractor, _google_uid), do: {:ok, contractor}

  @doc """
  Creates an invitation for the given email.
  """
  def create_invitation(attrs) do
    %Invitation{}
    |> Invitation.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Lists all contractors.
  """
  def list_contractors do
    Repo.all(from c in Contractor, order_by: [asc: c.name])
  end

  @doc """
  Lists active contractors only.
  """
  def list_active_contractors do
    Repo.all(from c in Contractor, where: c.active == true, order_by: [asc: c.name])
  end

  @doc """
  Activates or deactivates a contractor.
  """
  def set_active(%Contractor{} = contractor, active) when is_boolean(active) do
    contractor
    |> Contractor.changeset(%{active: active})
    |> Repo.update()
  end
end
