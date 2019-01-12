defmodule MecksUnit.MixProject do
  use Mix.Project

  def project do
    [
      app: :mecks_unit,
      version: "0.1.0",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      package: package()
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {MecksUnit.Application, []}
    ]
  end

  defp deps do
    [
      {:meck, "~> 0.8.8"}
    ]
  end

  defp description do
    """
    A simple Elixir package to mock functions within (asynchronous) ExUnit tests using Erlang's :meck library
    """
  end

  defp package do
    [
      name: "MecksUnit",
      maintainers: ["Paul Engel"],
      licenses: ["MIT"],
      links: %{github: "https://github.com/archan937/mecks_unit"}
    ]
  end
end
