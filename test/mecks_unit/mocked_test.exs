defmodule MecksUnit.MockedTest do
  use ExUnit.Case
  use MecksUnit.Case

  defmock Mocked.ModuleB do
    def module_b_func() do
      :returns_from_mocking
    end
  end

  defmock Mocked.ModuleA do
    def module_a_func() do
      :returns_from_mocking
    end
  end

  mocked_test "mocking works" do
    assert Mocked.func() === :returns_from_mocking
  end

  mocked_test "mocking works again" do
    assert Mocked.func2() === :returns_from_module_a
  end
end
