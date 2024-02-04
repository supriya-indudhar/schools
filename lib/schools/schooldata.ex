defmodule Schooldata do
  use Ecto.Schema

  schema "schooldata" do
    field :location, :string
    field :school_id, :integer
    field :school_name, :string
    field :school_address, :string
    field :teachers,  {:array, :map}, default: []
    field :class, :string
    field :section, :string
    field :students,  {:array, :map}, default: []
  end

  def changeset(attendance, params \\ %{}) do
    attendance
    |> Ecto.Changeset.cast(params, [:location, :school_id, :school_name, :school_address, :teachers, :class, :section, :students])
    |> Ecto.Changeset.validate_required([:location, :school_id, :school_name, :school_address, :teachers, :class, :section, :students])
  end
end
