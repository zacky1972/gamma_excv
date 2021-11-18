defmodule GammaExcv.MixProject do
  use Mix.Project

  def project do
    [
      app: :gamma_excv,
      version: "0.1.0-dev",
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:excv, "~> 0.1.0-dev", github: "zeam-vm/excv", branch: "main"},
      {:benchee, "~> 1.0", only: :dev},
      {:ok, "~> 0.2.0"},
      {:exla, "~> 0.1.0-dev", github: "elixir-nx/nx", sparse: "exla"},
      {:nx, "~> 0.1.0-dev", github: "elixir-nx/nx", sparse: "nx", override: true}
    ]
  end
end
