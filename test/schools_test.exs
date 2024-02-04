defmodule SchoolsTest do
  use ExUnit.Case
  doctest Schools

  test "greets the world" do
    assert Schools.hello() == :world
  end
end
