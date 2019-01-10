defmodule MecksUnit.Application do
  @moduledoc false

  use Application

  def start(_, _) do
    children = [MecksUnit.Server]
    Supervisor.start_link(children, strategy: :one_for_one, name: __MODULE__.Supervisor)
  end
end
