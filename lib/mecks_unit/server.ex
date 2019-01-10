defmodule MecksUnit.Server do
  @moduledoc false

  use GenServer
  @timeout 30_000

  def start_link(_options) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def register_mock_env(pid, mock_env) do
    GenServer.call(__MODULE__, {:register_mock_env, pid, mock_env}, @timeout)
  end

  def unregister_mock_env(pid) do
    GenServer.call(__MODULE__, {:unregister_mock_env, pid}, @timeout)
  end

  def running(pid) do
    GenServer.call(__MODULE__, {:running, pid}, @timeout)
  end

  def init(:ok) do
    {:ok, %{running: %{}}}
  end

  def handle_call({:register_mock_env, pid, mock_env}, _from, %{running: running} = state) do
    running = Map.put(running, pid, mock_env)
    {:reply, :ok, %{state | running: running}}
  end

  def handle_call({:unregister_mock_env, pid}, _from, %{running: running} = state) do
    running = Map.delete(running, pid)
    {:reply, :ok, %{state | running: running}}
  end

  def handle_call({:running, pid}, _from, %{running: running} = state) do
    ancestors =
      pid
      |> Process.info()
      |> Keyword.get(:dictionary)
      |> Keyword.get(:"$ancestors", [])

    running =
      Enum.find_value([pid] ++ ancestors, fn pid ->
        Map.get(running, pid)
      end)

    {:reply, running, state}
  end
end
