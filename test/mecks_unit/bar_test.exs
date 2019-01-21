defmodule MecksUnit.BarTest do
  use ExUnit.Case, async: true
  use MecksUnit.Case

  defmock List do
    def wrap(:bar_test), do: ~w(MecksUnit Bar Test)
  end

  mocked_test "parallel compiling" do
    task =
      Task.async(fn ->
        assert [:foo, :bar] == List.wrap([:foo, :bar])
        assert ~w(MecksUnit Bar Test) == List.wrap(:bar_test)
        assert called List.wrap(:bar_test)
      end)

    Task.await(task)
  end
end
