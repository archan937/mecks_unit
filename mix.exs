defmodule MecksUnit.MixProject do
  use Mix.Project

  def project do
    [
      app: :mecks_unit,
      version: "0.1.4",
      elixir: "~> 1.6",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      package: package(),
      name: "MecksUnit",
      source_url: "https://github.com/archan937/mecks_unit",
      docs: [
        main: "readme",
        extras: ["README.md"]
      ],
      elixirc_options: [warnings_as_errors: true]
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
      {:meck, "~> 0.8.8"},
      {:ex_doc, "~> 0.18.0", only: :dev, runtime: false}
    ]
  end

  defp description do
    """
    A simple Elixir package to elegantly mock module functions within (asynchronous) ExUnit tests using Erlang's :meck library
    """
  end

  defp package do
    [
      maintainers: ["Paul Engel"],
      licenses: ["MIT"],
      links: %{github: "https://github.com/archan937/mecks_unit"}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/modules"]
  defp elixirc_paths(_), do: ["lib"]
end
