defmodule TestApp.FooTest do
  use ExUnit.Case

  test "completes placeholder names" do
    assert TestApp.Foo.bar() == :baz
  end
end
