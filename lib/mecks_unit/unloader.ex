defmodule MecksUnit.Unloader do
  @moduledoc false

  use GenServer

  def register do
    formatters = Keyword.get(ExUnit.configuration(), :formatters, []) ++ [__MODULE__]
    ExUnit.configure(formatters: formatters)
  end

  def start_link(_options) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(_options), do: {:ok, %{}}

  def handle_cast({:suite_finished, _run_us, _load_us}, config) do
    MecksUnit.Server.mocked()
    |> Enum.map(fn {module, _func, _arity} -> module end)
    |> Enum.uniq()
    |> Enum.each(fn module ->
      try do
        if :meck.validate(module), do: :meck.unload(module)
      rescue
        ErlangError -> :ok
      end
    end)

    {:noreply, config}
  end

  def handle_cast(_event, config), do: {:noreply, config}
end
