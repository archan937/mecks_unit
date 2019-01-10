defmodule MecksUnit.Server do
  @moduledoc false

  use GenServer
  @timeout 30_000

  def start_link(_options) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def register_mock_env(owner_pid, mock_env) do
    GenServer.call(__MODULE__, {:register_mock_env, owner_pid, mock_env}, @timeout)
  end

  def unregister_mock_env(owner_pid) do
    GenServer.call(__MODULE__, {:unregister_mock_env, owner_pid}, @timeout)
  end

  def running(owner_pid) do
    GenServer.call(__MODULE__, {:running, owner_pid}, @timeout)
  end

  def init(:ok) do
    {:ok, %{running: %{}}}
  end

  def handle_call({:register_mock_env, owner_pid, mock_env}, _from, %{running: running} = state) do
    running = Map.put(running, owner_pid, mock_env)
    {:reply, :ok, %{state | running: running}}
  end

  def handle_call({:unregister_mock_env, owner_pid}, _from, %{running: running} = state) do
    running = Map.delete(running, owner_pid)
    {:reply, :ok, %{state | running: running}}
  end

  def handle_call({:running, owner_pid}, _from, %{running: running} = state) do
    {:reply, Map.get(running, owner_pid), state}
  end
end
