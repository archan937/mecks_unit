defmodule MecksUnit.Case do
  defmacro __using__(_opts) do
    quote do
      import MecksUnit.Case
      Module.register_attribute(__MODULE__, :preserved_mocks, accumulate: true, persist: false)
      Module.register_attribute(__MODULE__, :mocks, accumulate: true, persist: false)
      Module.register_attribute(__MODULE__, :flagged_mocks, accumulate: true, persist: false)
      @mock_index 0
    end
  end

  defmacro defmock({_alias, _meta, name}, options \\ [], block) do
    as = Keyword.get(options, :as)
    preserve = Keyword.get(options, :preserve) || !is_nil(as)
    attributes = Keyword.get(options, :attributes)

    quote do
      postfix = if unquote(preserve), do: "__INDEX__", else: @mock_index

      name = Module.concat([
        Enum.join([__MODULE__, postfix]),
        unquote_splicing(List.wrap(name))
      ])

      attrs = if unquote(attributes), do:
        Enum.map(unquote(attributes), fn attr ->
          val = Module.get_attribute(__MODULE__, attr, :default)
          if val == :default, do: nil, else:
            {:@, [line: 0], [{attr, [line: 0], [val]}]}
        end)
        |> Enum.filter(&(&1 != nil)),
      else: []

      block = unquote(Macro.escape(block))

      cond do
        unquote(as) != nil -> @flagged_mocks {unquote(as), name, attrs ++ block}
        unquote(preserve)  -> @preserved_mocks {name, attrs ++ block}
        true               -> @mocks {name, attrs ++ block}
      end
    end
  end

  defmacro mocked_test(message, options \\ [], pattern \\ nil, block) do
      {options, pattern} = cond do
        Keyword.keyword?(options) -> {options, pattern} 
        true -> {[], options}
      end
      args = if pattern != nil, do: [message, pattern], else: [message]

    quote do
      used_flags = if unquote(options) != nil, do: Keyword.get(unquote(options), :use), else: nil
      used_mocks = if used_flags != nil, do: Enum.filter(Enum.map(@flagged_mocks, fn
        {k, n, b} -> if k in used_flags, do: {n, b}, else: nil
      end), &(&1 != nil)), else: []

      MecksUnit.define_mocks(Enum.reverse(@preserved_mocks) ++ @mocks ++ used_mocks, __MODULE__, @mock_index)

      test unquote_splicing(args) do
        mock_env = Enum.join([__MODULE__, @mock_index])
        MecksUnit.Server.register_mock_env(self(), mock_env)
        unquote(block)
        MecksUnit.Server.unregister_mock_env(self())
      end

      Module.delete_attribute(__MODULE__, :mocks)
      @mock_index @mock_index + 1
    end
  end

  defmacro called({{:., _, [module, func]}, _, args}) do
    quote do
      MecksUnit.called(unquote(module), unquote(func), unquote(replace_ignore_pattern(args)))
    end
  end

  defmacro assert_called({{:., _, [module, func]}, _, args}) do
    quote do
      unless MecksUnit.called(
               unquote(module),
               unquote(func),
               unquote(replace_ignore_pattern(args))
             ) do
        calls =
          unquote(module)
          |> MecksUnit.history(unquote(func))
          |> Enum.reduce([""], fn {p, {m, f, a}, r}, calls ->
            p = inspect(p)
            m = String.replace("#{m}", "Elixir.", "")
            a = String.slice(inspect(a), 1..-2)
            r = inspect(r)
            ["#{p} #{m}.#{f}(#{a}) #=> #{r}"]
          end)

        raise ExUnit.AssertionError,
          message: "Expected call but did not receive it. Calls which were received:\n#{calls}"
      end
    end
  end

  defp replace_ignore_pattern(args) do
    for arg <- args do
      case arg do
        {:_, _, nil} -> :_
        tuple -> tuple
      end
    end
  end
end
