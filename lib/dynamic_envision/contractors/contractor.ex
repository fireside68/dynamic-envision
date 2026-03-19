defmodule DynamicEnvision.Contractors.Contractor do
  use Ecto.Schema
  import Ecto.Changeset

  @valid_roles ~w(contractor owner office)

  schema "contractors" do
    field :email, :string
    field :name, :string
    field :google_uid, :string
    field :roles, {:array, :string}, default: ["contractor"]
    field :active, :boolean, default: true
    field :is_clocked_in, :boolean, virtual: true, default: false

    timestamps(type: :utc_datetime)
  end

  def changeset(contractor, attrs) do
    contractor
    |> cast(attrs, [:email, :name, :google_uid, :roles, :active])
    |> validate_required([:email, :name, :roles])
    |> validate_roles()
    |> unique_constraint(:email)
    |> unique_constraint(:google_uid)
  end

  @doc """
  Returns true if the contractor has the given role.

      iex> has_role?(contractor, "owner")
      true
  """
  def has_role?(%__MODULE__{roles: roles}, role) when is_binary(role) do
    role in roles
  end

  def has_role?(_, _), do: false

  @doc """
  Returns true if the contractor has any admin-level role (owner or office).
  """
  def admin?(%__MODULE__{} = contractor) do
    has_role?(contractor, "owner") or has_role?(contractor, "office")
  end

  def admin?(_), do: false

  defp validate_roles(changeset) do
    case get_field(changeset, :roles) do
      nil ->
        add_error(changeset, :roles, "can't be blank")

      [] ->
        add_error(changeset, :roles, "must have at least one role")

      roles when is_list(roles) ->
        invalid = Enum.reject(roles, &(&1 in @valid_roles))

        if invalid == [] do
          changeset
        else
          add_error(changeset, :roles, "contains invalid roles: #{Enum.join(invalid, ", ")}")
        end

      _ ->
        add_error(changeset, :roles, "must be a list")
    end
  end
end
