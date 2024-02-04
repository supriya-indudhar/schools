defmodule Schools.Repo.Migrations.SchoolData do
  use Ecto.Migration

  def change do
    create table(:schooldata) do
      add :location, :string
      add :school_id, :integer
      add :school_name, :string
      add :school_address, :string
      add :teachers,  {:array, :map}, default: []
      add :class, :string
      add :section, :string
      add :students,  {:array, :map}, default: []
    end
  end
end
