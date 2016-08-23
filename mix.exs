defmodule Discorelic.Mixfile do
  use Mix.Project

  def project do
    [
      app: :discorelic,
      version: "0.0.1",
      elixir: "~> 1.2",
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      elixirc_paths: elixirc_paths(Mix.env),
      deps: deps,
      preferred_cli_env: [
        "coveralls":        :test,
        "coveralls.detail": :test,
        "coveralls.post":   :test,
        "coveralls.html":   :test,
        "coveralls.travis": :test,
      ],
      test_coverage: [ tool: ExCoveralls ]
    ]
  end

  def application do
    [
      mod: { Discorelic, [] },
      applications: [ :logger, :lhttpc ]
    ]
  end

  defp deps do
    [
      { :newrelic, "~> 0.1.0" },
      { :excoveralls, github: "parroty/excoveralls", only: :test }

    ]
  end
  defp elixirc_paths(:test), do: ["lib", "web", "test/support"]
  defp elixirc_paths(_),     do: ["lib", "web"]
end
