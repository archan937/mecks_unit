defmodule MecksUnit.FooTest do
  use ExUnit.Case, async: true
  use MecksUnit.Case

  defmock List do
    def wrap(:foo_test), do: ~w(MecksUnit Foo Test)
  end

  mocked_test "parallel compiling" do
    task =
      Task.async(fn ->
        assert [:foo, :bar] == List.wrap([:foo, :bar])
        assert ~w(MecksUnit Foo Test) == List.wrap(:foo_test)
        assert called(List.wrap(:foo_test))
      end)

    Task.await(task)
  end
end
