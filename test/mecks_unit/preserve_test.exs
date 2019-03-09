defmodule MecksUnit.PreserveTest do
  use ExUnit.Case, async: true
  use MecksUnit.Case

  defmock Foo do
    def bar, do: "what?!?"
  end

  defmock Foo.Bar.Baz, preserve: true do
    def qux(_string), do: "MOCKED :)"
  end

  mocked_test "mocked number 1" do
    assert "what?!?" = Foo.bar()
    assert "MOCKED :)" = Foo.Bar.Baz.qux("...")
  end

  mocked_test "mocked number 2" do
    assert "baz" = Foo.bar()
    assert "MOCKED :)" = Foo.Bar.Baz.qux("...")
  end

  mocked_test "mocked number 3" do
    assert "baz" = Foo.bar()
    assert "MOCKED :)" = Foo.Bar.Baz.qux("...")
  end

  test "actual number 1" do
    assert "Qux..." = Foo.Bar.Baz.qux("...")
  end

  test "actual number 2" do
    assert "baz" = Foo.bar()
    assert "Qux!!!" = Foo.Bar.Baz.qux("!!!")
  end

  defmock Foo do
    def bar, do: "what?!?!?!?!?!?"
  end

  defmock Foo.Bar.Baz do
    def qux(_string), do: "OVERRIDE ONCE :P"
  end

  mocked_test "mocked number 4" do
    assert "what?!?!?!?!?!?" = Foo.bar()
    assert "OVERRIDE ONCE :P" = Foo.Bar.Baz.qux("!!!")
  end

  test "actual number 3" do
    assert "baz" = Foo.bar()
    assert "Qux, quux" = Foo.Bar.Baz.qux(", quux")
  end

  mocked_test "mocked number 5" do
    assert "baz" = Foo.bar()
    assert "MOCKED :)" = Foo.Bar.Baz.qux("...")
  end

  defmock Foo.Bar.Baz, preserve: true do
    def qux(_string), do: "OVERRIDE ALL!"
  end

  mocked_test "mocked number 6" do
    assert "baz" = Foo.bar()
    assert "OVERRIDE ALL!" = Foo.Bar.Baz.qux(", quux")
  end

  mocked_test "mocked number 7" do
    assert "baz" = Foo.bar()
    assert "OVERRIDE ALL!" = Foo.Bar.Baz.qux(", quux")
  end

  test "actual number 4" do
    assert "baz" = Foo.bar()
    assert "Qux, quux" = Foo.Bar.Baz.qux(", quux")
  end

  defmock Foo.Bar.Baz, preserve: true do
    def qux(_string), do: "OVERRIDE ALL FOREVER!"
  end

  mocked_test "mocked number 8" do
    assert "baz" = Foo.bar()
    assert "OVERRIDE ALL FOREVER!" = Foo.Bar.Baz.qux(", quux")
  end

  mocked_test "mocked number 9" do
    assert "baz" = Foo.bar()
    assert "OVERRIDE ALL FOREVER!" = Foo.Bar.Baz.qux(", quux")
  end

  test "actual number 5" do
    assert "baz" = Foo.bar()
    assert "Qux, quux" = Foo.Bar.Baz.qux(", quux")
  end
end
