defmodule DynamicEnvision.Shifts.Shift do
  use Ecto.Schema
  import Ecto.Changeset

  alias DynamicEnvision.Contractors.Contractor

  schema "shifts" do
    belongs_to :contractor, Contractor
    field :clocked_in_at, :utc_datetime
    field :clocked_out_at, :utc_datetime
    field :note, :string

    timestamps(type: :utc_datetime)
  end

  def changeset(shift, attrs) do
    shift
    |> cast(attrs, [:contractor_id, :clocked_in_at, :clocked_out_at, :note])
    |> validate_required([:contractor_id, :clocked_in_at])
    |> foreign_key_constraint(:contractor_id)
  end
end
