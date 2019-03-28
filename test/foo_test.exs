defmodule FooTest do
  use ExUnit.Case, async: true
  use MecksUnit.Case

  defmock Foo, preserve: true do
    def bar(_x), do: 1
  end

  mocked_test "this should work" do
    assert Foo.bar(nil) == 1
  end

  mocked_test "this should work as well" do
    assert Foo.bar(nil) == 1
  end
end
