defmodule MecksUnit do
  @moduledoc false

  def defmock(module, spec) do
    spec
    |> map_functions()
    |> Enum.each(fn {mock_env, name, arity, func} ->
      mexpect(module, mock_env, name, arity).(func)
    end)
  end

  defp map_functions(spec) do
    Enum.reduce(spec, [], fn {mock_env, functions}, acc ->
      Enum.reduce(functions, acc, fn {name, func}, acc ->
        arity =
          func
          |> Function.info()
          |> Keyword.get(:arity)

        acc ++ [{mock_env, name, arity, func}]
      end)
    end)
  end

  defp mexpect(module, mock_env, name, arity) do
    arguments = Macro.generate_arguments(arity, :Elixir)

    quote do
      fn func ->
        :meck.expect(unquote(module), unquote(name), fn unquote_splicing(arguments) ->
          arguments = [unquote_splicing(arguments)]
          passthrough = fn(arguments) ->
            :meck.passthrough(arguments)
          end

          if unquote(mock_env) == MecksUnit.Server.running(self()) do
            try do
              case func.(unquote_splicing(arguments)) do
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
        end)
      end
    end
    |> Code.eval_quoted()
    |> elem(0)
  end
end
