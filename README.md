# MecksUnit

A simple Elixir package to mock functions within ExUnit tests using Erlang's `:meck` library

## Installation

To install MecksUnit, please do the following:

  1. Add mecks_unit to your list of dependencies in `mix.exs`:

      ```elixir
      def deps do
        [
          {:mecks_unit, "~> 0.1.0", only: :test}
        ]
      end
      ```

## Usage

Mocking module functions is pretty straightforward and done as follows:

  1. Add `use MecksUnit.Case` at the beginning of your test file
  2. Use `defmock` as if you would define the original module with `defmodule` containing mocked functions
  3. Use `mocked_test` as if you would define a normal ExUnit `test` after having defined all the required mock modules
  4. Enjoy ;)

Please note that the defined mock modules only apply to the first `mocked_test` encountered. So they are isolated.

### An example

The following is a working example defined in [test/mecks_unit_test.exs](https://github.com/archan937/mecks_unit/blob/master/test/mecks_unit_test.exs)

  ```elixir
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
          assert "Bar" == String.trim("  Foo  ", "!")
          assert "  Surprise!  " == String.trim("  Paul  ", "!")
          assert "MecksUnit" == String.trim("  MecksUnit  ")
          assert "Paul Engel" == String.trim("  Paul Engel  ", " ")
          assert [1, 2, 3, 4] == List.wrap(:foo)
          assert [] == List.wrap(nil)
          assert [:bar] == List.wrap(:bar)
          assert [:foo, :bar] == List.wrap([:foo, :bar])
        end)

      Task.await(task)
    end

    test "using the original module functions" do
      task =
        Task.async(fn ->
          assert "Paul" == String.trim("  Paul  ")
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
