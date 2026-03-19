defmodule DynamicEnvision.Shifts do
  import Ecto.Query

  alias DynamicEnvision.Repo
  alias DynamicEnvision.Shifts.Shift

  @doc """
  Clocks in a contractor. Returns `{:error, :already_clocked_in}` if an open shift exists.
  """
  def clock_in(contractor_id) do
    if current_shift(contractor_id) do
      {:error, :already_clocked_in}
    else
      %Shift{}
      |> Shift.changeset(%{
        contractor_id: contractor_id,
        clocked_in_at: DateTime.utc_now() |> DateTime.truncate(:second)
      })
      |> Repo.insert()
    end
  end

  @doc """
  Clocks out the currently open shift for a contractor.
  Optionally sets a note. Returns `{:error, :not_clocked_in}` if no open shift exists.
  """
  def clock_out(contractor_id, note \\ nil) do
    case current_shift(contractor_id) do
      nil ->
        {:error, :not_clocked_in}

      shift ->
        attrs = %{clocked_out_at: DateTime.utc_now() |> DateTime.truncate(:second)}
        attrs = if note && note != "", do: Map.put(attrs, :note, note), else: attrs

        shift
        |> Shift.changeset(attrs)
        |> Repo.update()
    end
  end

  @doc """
  Returns the open (not yet clocked out) shift for a contractor, or nil.
  """
  def current_shift(contractor_id) do
    Repo.one(
      from s in Shift,
        where: s.contractor_id == ^contractor_id and is_nil(s.clocked_out_at),
        limit: 1
    )
  end

  @doc """
  Returns all contractors with their current shift (nil if clocked out), ordered by name.
  Each entry is a map: %{contractor: %Contractor{}, current_shift: %Shift{} | nil}
  """
  def list_all_with_current_shift do
    alias DynamicEnvision.Contractors.Contractor

    Repo.all(
      from c in Contractor,
        left_join: s in Shift,
        on: s.contractor_id == c.id and is_nil(s.clocked_out_at),
        order_by: [asc: c.name],
        select: {c, s}
    )
    |> Enum.map(fn {contractor, shift} ->
      %{contractor: contractor, current_shift: shift}
    end)
  end

  @doc """
  Returns total hours worked in the current week (Mon 00:00 UTC to now).
  Returns a float rounded to 2 decimal places.
  """
  def weekly_hours(contractor_id) do
    now = DateTime.utc_now()
    # Days since Monday (Monday = 0)
    day_of_week = Date.day_of_week(DateTime.to_date(now)) - 1
    week_start =
      now
      |> DateTime.to_date()
      |> Date.add(-day_of_week)
      |> DateTime.new!(~T[00:00:00], "Etc/UTC")

    shifts =
      Repo.all(
        from s in Shift,
          where:
            s.contractor_id == ^contractor_id and
              s.clocked_in_at >= ^week_start
      )

    total_seconds =
      Enum.reduce(shifts, 0, fn shift, acc ->
        finish = shift.clocked_out_at || now
        acc + DateTime.diff(finish, shift.clocked_in_at, :second)
      end)

    Float.round(total_seconds / 3600, 2)
  end

  @doc """
  Returns recent shifts for a contractor, ordered by clocked_in_at DESC.
  """
  def list_shifts(contractor_id, opts \\ []) do
    limit = Keyword.get(opts, :limit, 10)

    Repo.all(
      from s in Shift,
        where: s.contractor_id == ^contractor_id,
        order_by: [desc: s.clocked_in_at],
        limit: ^limit
    )
  end
end
