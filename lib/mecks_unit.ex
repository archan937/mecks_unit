defmodule MecksUnit do
  @moduledoc false

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
              returned -> returned
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

  def called(module, func, arguments) do
    module
    |> history(func)
    |> Enum.any?(fn {_pid, {_module, _func, args}, _returned} ->
      if length(arguments) == length(args) do
        arguments
        |> Enum.with_index()
        |> Enum.all?(fn {arg, index} ->
          (arg == :_) || (Enum.at(args, index) == arg)
        end)
      end
    end)
  end

  def history(module, func) do
    pid = self()

    module
    |> :meck.history()
    |> Enum.reduce([], fn
      {^pid, {^module, ^func, _args}, _returned} = call, calls ->
        calls ++ [call]
      _, calls ->
        calls
    end)
  end
end
