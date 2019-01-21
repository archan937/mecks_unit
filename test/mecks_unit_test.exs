defmodule Foo do
  def trim(string) do
    String.trim(string)
  end
end

defmodule MecksUnitTest do
  use ExUnit.Case, async: true
  use MecksUnit.Case

  defmock String do
    def trim("  Paul  "), do: "Engel"
    def trim("  Foo  ", "!"), do: "Bar"
    def trim(_, "!"), do: {:passthrough, ["  Surprise!  !!!!", "!"]}
    def trim(_, _), do: :passthrough
  end

  defmock List do
    def wrap(:foo), do: [1, 2, 3, 4]
  end

  mocked_test "using mocked module functions" do
    task =
      Task.async(fn ->
        assert "Engel" == String.trim("  Paul  ")
        assert "Engel" == Foo.trim("  Paul  ")
        assert "Bar" == String.trim("  Foo  ", "!")
        assert "  Surprise!  " == String.trim("  Paul  ", "!")
        assert "MecksUnit" == String.trim("  MecksUnit  ")
        assert "Paul Engel" == String.trim("  Paul Engel  ", " ")
        assert [1, 2, 3, 4] == List.wrap(:foo)
        assert [] == List.wrap(nil)
        assert [:bar] == List.wrap(:bar)
        assert [:foo, :bar] == List.wrap([:foo, :bar])
        assert called(List.wrap(:foo))
      end)

    Task.await(task)
  end

  test "using the original module functions" do
    task =
      Task.async(fn ->
        assert "Paul" == String.trim("  Paul  ")
        assert "Paul" == Foo.trim("  Paul  ")
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

  defmock String do
    def trim("  Paul  "), do: "PAUL :)"
  end

  defmock List do
    def wrap([1, 2, 3, 4]), do: [5, 6, 7, 8]
    def wrap(nil), do: ~w(Surprise)
  end

  mocked_test "second time using different mocked module functions" do
    task =
      Task.async(fn ->
        assert "PAUL :)" == String.trim("  Paul  ")
        assert "PAUL :)" == Foo.trim("  Paul  ")
        assert "  Foo  " == String.trim("  Foo  ", "!")
        assert "  Paul  " == String.trim("  Paul  ", "!")
        assert "MecksUnit" == String.trim("  MecksUnit  ")
        assert "Paul Engel" == String.trim("  Paul Engel  ", " ")
        assert [:foo] == List.wrap(:foo)
        assert ["Surprise"] == List.wrap(nil)
        assert [:bar] == List.wrap(:bar)
        assert [:foo, :bar] == List.wrap([:foo, :bar])
        assert [5, 6, 7, 8] == List.wrap([1, 2, 3, 4])
        assert_called(String.trim(_))
      end)

    Task.await(task)
  end
end
