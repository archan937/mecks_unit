defmodule Mocked do
  def func() do
    Mocked.ModuleA.call_module_b_func()
  end

  def func2() do
    Mocked.ModuleB.module_a_func()
  end
end

defmodule Mocked.ModuleA do
  alias Mocked.ModuleB

  def module_a_func() do
    :returns_from_module_a
  end

  def call_module_b_func() do
    ModuleB.module_b_func()
  end
end

defmodule Mocked.ModuleB do
  alias Mocked.ModuleA

  def module_b_func() do
    :returns_from_module_b
  end

  def module_a_func() do
    ModuleA.module_a_func()
  end
end
