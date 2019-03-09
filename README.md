# MecksUnit [![Build Status](https://travis-ci.org/archan937/mecks_unit.svg?branch=master)](https://travis-ci.org/archan937/mecks_unit)

A simple Elixir package to elegantly mock module functions within (asynchronous) ExUnit tests using Erlang's `:meck` library

## Installation

To install MecksUnit, please do the following:

  1. Add mecks_unit to your list of dependencies in `mix.exs`:

      ```elixir
      def deps do
        [
          {:mecks_unit, "~> 0.1.7", only: :test}
        ]
      end
      ```

## Usage

Mocking module functions is pretty straightforward and done as follows:

  1. Add `use MecksUnit.Case` at the beginning of your test file
  2. Use `defmock` as if you would define the original module with `defmodule` containing mocked functions
  3. Use `mocked_test` as if you would define a normal ExUnit `test` after having defined all the required mock modules
  4. Add `MecksUnit.mock()` in your `test/test_helper.exs` file
  5. Enjoy ;)

Please note that the defined mock modules only apply to the first `mocked_test` encountered.
So they are isolated (despite of `:meck` having an unfortunate global effect) as MecksUnit takes care of it.
Also, non-matching function heads within the mock module will result in invoking the original module function as well.

As of version `0.1.2`, you can assert function calls using `called` (returns a boolean) or `assert_called` (raises an
error when not having found a match) within your test block. Use `_` to match any argument as if you would pattern match.

Prior to version `0.1.3`, you would very often get `:meck` related compile errors when using MecksUnit in multiple test files.
From that version on, this problem is solved. Happy testing! ^^

### Define mock module for entire test case

As of version `0.1.7`, you can "preserve" a mocked module definition for the rest of the test case by adding `preserve: true`.

  ```elixir
  defmock List, preserve: true do
    def wrap(:foo), do: [1, 2, 3, 4]
  end
  ```

This behaviour is intended to be implemented as natural as possible. Therefore, you can override a preserved mock module once
just by inserting a "regular" mock module definition:

  ```elixir
  defmock List, preserve: true do
    def wrap(:foo), do: [1, 2, 3, 4]
  end

  # mocked tests ...

  defmock List do
    def wrap(:foo), do: ["this only applies to the next `mocked_test`"]
  end
  ```

Also, you can override a preserved mock module for the rest of the test case by using `preserve: true` again.

  ```elixir
  defmock List, preserve: true do
    def wrap(:foo), do: [1, 2, 3, 4]
  end

  # mocked tests ...

  defmock List do
    def wrap(:foo), do: ["this only applies to the next `mocked_test`"]
  end

  # mocked tests ...

  defmock List, preserve: true do
    def wrap(:foo), do: [5, 6, 7, 8]
  end
  ```

Please note that this behaviour is also tested in [test/mecks_unit/preserve_test.exs](https://github.com/archan937/mecks_unit/blob/master/test/mecks_unit/preserve_test.exs).

### A full example

The following is a working example defined in [test/mecks_unit_test.exs](https://github.com/archan937/mecks_unit/blob/master/test/mecks_unit_test.exs)

  ```elixir
  # (in test/test_helper.exs)

  ExUnit.start()
  MecksUnit.mock()
  ```

  ```elixir
  # (in test/mecks_unit_test.exs)

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
          assert called List.wrap(:foo)
          assert_called String.trim(_)
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
  end
  ```

Please note that you can delegate to the original implementation by either returning `:passthrough` (which forwards the given arguments)
or return a tuple `{:passthrough, arguments}` in which you can alter the arguments yourself.

## Asynchronous testing

Unlike [Mock](https://github.com/jjh42/mock), MecksUnit supports running mocked tests asynchronously. W00t! ^^

## License

Copyright (c) 2019 Paul Engel, released under the MIT License

http://github.com/archan937 – http://twitter.com/archan937 – pm_engel@icloud.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
