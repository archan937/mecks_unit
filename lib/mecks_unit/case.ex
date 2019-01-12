defmodule MecksUnit.Case do
  defmacro __using__(_opts) do
    quote do
      import MecksUnit.Case, only: [defmock: 2, mocked_test: 2, define_mocks: 3]
      Module.register_attribute(__MODULE__, :mocks, accumulate: true, persist: false)
      @mock_index 0
    end
  end

  defmacro defmock({_alias, _meta, name}, do: block) do
    quote do
      name = Module.concat([Enum.join([__MODULE__, @mock_index]), unquote_splicing(List.wrap(name))])
      block = unquote(Macro.escape(block))
      @mocks {name, block}
    end
  end

  defmacro mocked_test(message, block) do
    quote do
      define_mocks(@mocks, __MODULE__, @mock_index)

      test unquote(message) do
        mock_env = Enum.join([__MODULE__, @mock_index])
        MecksUnit.Server.register_mock_env(self(), mock_env)
        unquote(block)
        MecksUnit.Server.unregister_mock_env(self())
      end

      Module.delete_attribute(__MODULE__, :mocks)
      @mock_index @mock_index + 1
    end
  end

  def define_mocks(mocks, test_module, mock_index) do
    prefix = [Atom.to_string(test_module), mock_index, "."] |> Enum.join()

    Enum.each(mocks, fn {mock_module, block} ->
      original_module =
        mock_module
        |> Atom.to_string()
        |> String.replace(prefix, "Elixir.")
        |> String.to_atom()

      if function_exported?(mock_module, :__info__, 1) do
        IO.warn("Already defined mock module for #{original_module}")
      else
        Code.eval_quoted({:defmodule, [import: Kernel], [mock_module, [do: block]]})
        Enum.each(mock_module.__info__(:functions), fn {func, arity} ->
          mock_function = to_mock_function(original_module, func, arity)
          :meck.expect(original_module, func, mock_function)
        end)
      end

    end)
  end

  defp to_mock_function(module, func, arity) do
    arguments = Macro.generate_arguments(arity, :Elixir)
    module =
      case module do
        [_head | _tail] = module -> module
        module -> [module]
      end

    quote do
      fn unquote_splicing(arguments) ->

        mock_env = MecksUnit.Server.running(self())
        mock_module = Module.concat([mock_env, unquote_splicing(module)])

        arguments = [unquote_splicing(arguments)]
        passthrough = fn(arguments) ->
          :meck.passthrough(arguments)
        end

        if mock_env && function_exported?(mock_module, unquote(func), unquote(arity)) do
          try do
            case apply(mock_module, unquote(func), arguments) do
              {:passthrough, arguments} -> passthrough.(arguments)
              :passthrough -> passthrough.(arguments)
              value -> value
            end
          rescue
            FunctionClauseError ->
              passthrough.(arguments)
          end
        else
          passthrough.(arguments)
        end

      end
    end
    |> Code.eval_quoted()
    |> elem(0)
  end
end
