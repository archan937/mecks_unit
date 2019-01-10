defmodule MecksUnit.MixProject do
  use Mix.Project

  def project do
    [
      app: :mecks_unit,
      version: "0.1.0",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps()
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
end
