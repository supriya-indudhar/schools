defmodule Schools do
  alias Attendance
  alias Schools.Repo
  alias Schooldata
  import Ecto.Query
  @moduledoc """
  Documentation for `Schools`.
  """


    # Schools.mark_absent_attendance("Bangalore",1,"nursary", "A",  Date.utc_today(), [{1,0}, {2,1},{3,0}])
    # school_id = 1
    # class = "nursary"
    # section = "A"
    # absentlist = {student_id, date, value}
    # absent_list = [{1, 0}, {2, 1},{3, 2}]
    # Schools.mark_absent_attendance("Bangalore",1,"nursary", "A",  Date.utc_today(), [{1,0}, {2,0},{3,0}])
  def mark_absent_attendance(location, school_id, class, section, date, absent_list) do
    query = from(a in Attendance, where: a.school_id == ^school_id and a.class == ^class and a.section == ^section)
    case Repo.all(query) do
      [] ->
        updated_list = create_map(absent_list)
        data = %{location: location, school_id: school_id, class: class, section: section, date: date, absent_list: updated_list}
        changeset = Attendance.changeset(%Attendance{}, data)
        Repo.insert(changeset)

      [data]  ->
        old_absent_list = data.absent_list |> Enum.map(fn x -> Map.new(x, fn {k, v} -> {String.to_atom(k), v} end)end)
        new_ab_list = create_map(absent_list)

        updated_list =
          case check_student_id_is_present(old_absent_list,new_ab_list) do
            [] ->
                  []
            unmarked_attendance_stud_ids ->
              IO.inspect(unmarked_attendance_stud_ids, label: "This student id attendance is not marked" )
              Enum.map(unmarked_attendance_stud_ids, fn x -> Enum.filter(new_ab_list, fn map -> map.student_id == x end) end) |>  List.flatten()
          end

          if updated_list != [] do
            new_list = old_absent_list ++ updated_list
            IO.inspect(new_list)
            changeset = Attendance.changeset(data, %{absent_list: new_list})
            case Repo.update(changeset) do
              {:ok, _newdata} ->
                  :success
              {:error, changeset}  ->
                {:error, changeset}
            end

          else
              IO.puts("student id attendance is already marked" )
          end

    end




  end

  # Schools.get_attendance_absenties(1, "nursary", "A")
  def get_attendance_absenties(school_id, class, section) do
    query = from(a in Attendance, where: a.school_id == ^school_id and a.class == ^class and a.section == ^section)
    Repo.all(query)
  end

  # Schools.get_class_attendance("Bangalore", 1, "nursary", "A")
  def get_class_attendance(location, school_id, class, section) do
    query = (from s in Schooldata, where: s.location == ^location and s.school_id == ^school_id and s.class == ^class and s.section == ^section)
    [data] = Repo.all(query)
      query1 = from(a in Attendance, where: a.school_id == ^school_id and a.class == ^class and a.section == ^section)
      [ab_list] = Repo.all(query1)
      create_attendance_list(data.students, ab_list.absent_list)
  end

  # Schools.get_attendance_percenatge_of_class("Bangalore", 1, "nursary", "A")
  def get_attendance_percenatge_of_class(location, school_id, class, section) do
    query = (from s in Schooldata, where: s.location == ^location and s.school_id == ^school_id and s.class == ^class and s.section == ^section)
    [data] = Repo.all(query)
     number_of_students = length(data.students)

     query1 = from(a in Attendance, where: a.school_id == ^school_id and a.class == ^class and a.section == ^section)
     [data1] = Repo.all(query1)
     num_of_ab = length(data1.absent_list)

     num_of_ab/number_of_students * 100
  end


  # Schools.update_attendance(1, "nursary", "A", [{4, 0}])
  #  Schools.update_attendance(1, "nursary", "A", [{1,2}, {2,3},{3,2},{4,0}])
  def update_attendance(school_id, class, section, student_data) do
    query = from(a in Attendance, where: a.school_id == ^school_id and a.class == ^class and a.section == ^section)
    [data] = Repo.all(query)
    absent_list = data.absent_list |> Enum.map(fn x -> Map.new(x, fn {k, v} -> {String.to_atom(k), v} end)end)
    new_updated_list = create_map(student_data)

    IO.inspect(absent_list, label: "absent_list")
    IO.inspect(new_updated_list, label: "updated_list")

    [updated_list] =
    case check_student_id_is_present(absent_list,new_updated_list) do
      [] ->
        new_updated_list

      unmarked_attendance_stud_ids ->
        IO.inspect(unmarked_attendance_stud_ids, label: "This student id attendance is not marked" )
        Enum.map(unmarked_attendance_stud_ids, fn x -> Enum.filter(new_updated_list, fn map -> map.student_id != x end) end)
    end

    IO.inspect(updated_list, label: "updated_list")

    if updated_list != [] do
      new = Enum.zip(absent_list,updated_list) |> Enum.map(fn {map1, map2} -> Map.merge(map1, map2) end)
      new_list = Enum.filter(new, fn x -> x.value != 1 end)

       changeset = Attendance.changeset(data, %{absent_list: new_list})
       case Repo.update(changeset) do
         {:ok, _newdata} ->
             :success
         {:error, changeset}  ->
           {:error, changeset}
       end
      else
        IO.puts("student id attendance is not marked" )
      end

  end

  #teachers[%{id: 11, name: "Deepa", age: 28}, %{id: 22, name: "Harish", age: 33}, %{id: 33, name: "joseph", age: 35}]
  #students[{id: 1, name: "Shiv", age: 5}, {id: 2, name: "Kate", age: 4}, {id: 3, name: "Frakie", age: 5.2}]
  # Schools.add_school_details("Bangalore", 1, "Eurokids", "Vijaynagar", [%{id: 11, name: "Deepa", age: 28}, %{id: 22, name: "Harish", age: 33}, %{id: 33, name: "joseph", age: 35}], "nursary", "A", [%{student_id: 1, name: "Shiv", age: 5}, %{student_id: 2, name: "Kate", age: 4}, %{student_id: 3, name: "Frakie", age: 5}, %{student_id: 4, name: "Srusti", age: 5}, %{student_id: 5, name: "John", age: 5}, %{student_id: 6, name: "Dev", age: 5}])

  def add_school_details(location, school_id, school_name, school_address, teachers, class, section, students) do
    data = %{location: location, school_id: school_id, school_name: school_name, school_address: school_address, teachers: teachers, class: class, section: section, students: students}
    changeset = Schooldata.changeset(%Schooldata{}, data)
    Repo.insert(changeset)
  end

  def get_school_data(location, school_id) do
    query = from(s in Schooldata, where: s.location == ^location and s.school_id == ^school_id)
    Repo.all(query)
  end

  def update_student_data(location, school_id, class, section, student_data) do
    query = (from s in Schooldata, where: s.location == ^location and s.school_id == ^school_id and s.class == ^class and s.section == ^section)
    [data] = Repo.all(query)
     new_data = data.students ++ student_data

     changeset = Schooldata.changeset(data, %{students: new_data})
     case Repo.update(changeset) do
       {:ok, _newdata} ->
           :success
       {:error, changeset}  ->
         {:error, changeset}
     end
  end

  # Schools.delete_all_student_data("Bangalore", 1, "nursary", "A")
  def delete_all_student_data(location, school_id, class, section) do
    query = from(s in Schooldata, where: s.location == ^location and s.school_id == ^school_id and s.class == ^class and s.section == ^section)
    Repo.delete_all(query)

  end

  # Schools.delete_attendance(1, "nursary", "A", Date.utc_today())
  def delete_attendance(school_id, class, section, date) do
    query = from(a in Attendance, where: a.school_id == ^school_id and a.class == ^class and a.section == ^section and a.date == ^date)
    Repo.delete_all(query)
  end

  defp create_map(list_of_tuples) do
    Enum.map(list_of_tuples, fn x -> %{student_id: elem(x,0), value: elem(x,1)} end)
  end

  def create_attendance_list(list1, list2) do
      class_std = Enum.map(list1, & &1["student_id"])
      ab_std = Enum.map(list2, & &1["student_id"])

      Enum.map(class_std, fn x ->

      case Enum.member?(ab_std, x) do
        true -> %{student_id: x, value: 0 }
        false -> %{student_id: x, value: 1}
      end end)
  end

  def check_student_id_is_present(list_of_map, list_of_tuple) do
    old_data = Enum.map(list_of_map, & &1[:student_id])
    new_data = Enum.map(list_of_tuple, & &1[:student_id])
    Enum.filter(new_data, fn x -> Enum.member?(old_data, x) == false end)
  end


end
