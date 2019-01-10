defmodule MecksUnitTest do
  use ExUnit.Case, async: true

  import MecksUnit.Case

  mocked_test :mocking_demo, "using mocked module functions" do
    task =
      Task.async(fn ->
        assert "Engel" == String.trim("  Paul  ")
        assert "Bar" == String.trim("  Foo  ", "!")
        assert "  Surprise!  " == String.trim("  Paul  ", "!")
        assert "MecksUnit" == String.trim("  MecksUnit  ")
        assert "Paul Engel" == String.trim("  Paul Engel  ", " ")
        assert [1, 2, 3, 4] == List.wrap(:foo)
        assert [] == List.wrap(nil)
        assert [:bar] == List.wrap(:bar)
        assert [:foo, :bar] == List.wrap([:foo, :bar])
      end)

    Task.await(task)
  end

  test "using the original module functions" do
    task =
      Task.async(fn ->
        assert "Paul" == String.trim("  Paul  ")
        assert "  Foo  " == String.trim("  Foo  ", "!")
        assert "  Paul  " == String.trim("  Paul  ", "!")
        assert "MecksUnit" == String.trim("  MecksUnit  ")
        assert "Paul Engel" == String.trim("  Paul Engel  ", " ")
        assert [:foo] == List.wrap(:foo)
        assert [] == List.wrap(nil)
        assert [:bar] == List.wrap(:bar)
        assert [:foo, :bar] == List.wrap([:foo, :bar])
      end)

    Task.await(task)
  end
end
