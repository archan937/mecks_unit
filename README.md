# MecksUnit

A simple Elixir package to mock functions within ExUnit tests using Erlang's `:meck` library

## Installation

To install MecksUnit, please do the following:

  1. Add mecks_unit to your list of dependencies in `mix.exs`:

      ```elixir
      def deps do
        [
          {:mecks_unit, "~> 0.1.0", git: "https://github.com/archan937/mecks_unit.git", only: :test}
        ]
      end
      ```

## Usage

### Define mocked functions

For defining mocked module functions, you need to define them in your `test/test_helper.exs` and writing
them is pretty straightforward:

  ```elixir
  ExUnit.start()

  import MecksUnit

  defmock String, [
    mocking_demo: [
      trim: fn
        "  Paul  " ->
          "Engel"
      end,
      trim: fn
        "  Foo  ", "!" ->
          "Bar"
        _, to_trim ->
          case to_trim do
            "!" ->
              {:passthrough, ["  Surprise!  !!!!", "!"]}
            _ ->
              :passthrough
          end
      end
    ]
  ]

  defmock List, [
    mocking_demo: [
      wrap: fn
        :foo ->
          [1, 2, 3, 4]
      end
    ]
  ]
  ```

MecksUnit uses so called "mock environments" (`mock_env`) to distinct whether or not apply the mocked function.
In this case, the mock environment is `:mocking_demo`. You need to pattern match function heads in order to override.

When wanting to delegate to the original implementation either return `:passthrough` (which passes on the original arguments)
or return a tuple `{:passthrough, arguments}` in which you can override the used arguments yourself.

### Start using the mocked module functions within tests

  ```elixir
  defmodule MyAwesomeTest do
    use ExUnit.Case

    import MecksUnit.Case

    mocked_test :mocking_demo, "using mocked module functions" do
      assert "Engel" == String.trim("  Paul  ")
      assert "Bar" == String.trim("  Foo  ", "!")
      assert "  Surprise!  " == String.trim("  Paul  ", "!")
      assert "MecksUnit" == String.trim("  MecksUnit  ")
      assert "Paul Engel" == String.trim("  Paul Engel  ", " ")
      assert [1, 2, 3, 4] == List.wrap(:foo)
      assert [] == List.wrap(nil)
      assert [:bar] == List.wrap(:bar)
      assert [:foo, :bar] == List.wrap([:foo, :bar])
    end

    test "using the original module functions" do
      assert "Paul" == String.trim("  Paul  ")
      assert "  Foo  " == String.trim("  Foo  ", "!")
      assert "  Paul  " == String.trim("  Paul  ", "!")
      assert "MecksUnit" == String.trim("  MecksUnit  ")
      assert "Paul Engel" == String.trim("  Paul Engel  ", " ")
      assert [:foo] == List.wrap(:foo)
      assert [] == List.wrap(nil)
      assert [:bar] == List.wrap(:bar)
      assert [:foo, :bar] == List.wrap([:foo, :bar])
    end
  end
  ```

## License

Copyright (c) 2019 Paul Engel, released under the MIT License

http://github.com/archan937 – http://twitter.com/archan937 – pm_engel@icloud.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
