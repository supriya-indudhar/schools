defmodule Schools.Repo.Migrations.Attendance do
  use Ecto.Migration

  def change do
    create table(:attendance) do
      add :school_id, :integer
      add :class, :string
      add :section, :string
      add :date, :date
      add :absent_list, {:array, :map}, default: []
      end
  end
end
