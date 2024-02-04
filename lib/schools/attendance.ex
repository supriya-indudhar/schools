defmodule Attendance do
  use Ecto.Schema

  schema "attendance" do
    field :school_id, :integer
    field :class, :string
    field :section, :string
    field :date, :date
    field :absent_list, {:array, :map}, default: []
  end

  #absent_list {:student_id, :value}
  def changeset(attendance, params \\ %{}) do
    attendance
    |> Ecto.Changeset.cast(params, [:school_id, :class, :section, :date, :absent_list])
    |> Ecto.Changeset.validate_required([:school_id, :class, :section, :date, :absent_list])
  end
end
