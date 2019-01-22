defmodule TestAppTest do
  use ExUnit.Case
  use MecksUnit.Case

  test "greets the world" do
    assert TestApp.hello() == :world
  end

  defmock TestApp do
    def hello, do: :goodbye
  end

  mocked_test "sings Hello, Goodbye" do
    assert TestApp.hello() == :goodbye
  end

  test "greets the world again" do
    assert TestApp.hello() == :world
  end
end
