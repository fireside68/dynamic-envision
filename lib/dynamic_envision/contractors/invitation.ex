defmodule DynamicEnvision.Contractors.Invitation do
  use Ecto.Schema
  import Ecto.Changeset

  schema "invitations" do
    field :email, :string
    field :token, :string
    field :roles, {:array, :string}, default: ["contractor"]
    field :accepted_at, :utc_datetime
    field :expires_at, :utc_datetime

    timestamps(type: :utc_datetime)
  end

  def changeset(invitation, attrs) do
    invitation
    |> cast(attrs, [:email, :roles, :expires_at])
    |> validate_required([:email, :roles, :expires_at])
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+$/, message: "must be a valid email address")
    |> put_token()
    |> unique_constraint(:email)
    |> unique_constraint(:token)
  end

  def valid?(%__MODULE__{accepted_at: nil, expires_at: expires_at}) do
    DateTime.compare(expires_at, DateTime.utc_now()) == :gt
  end

  def valid?(_), do: false

  defp put_token(changeset) do
    if get_field(changeset, :token) do
      changeset
    else
      token = :crypto.strong_rand_bytes(32) |> Base.url_encode64()
      put_change(changeset, :token, token)
    end
  end
end
