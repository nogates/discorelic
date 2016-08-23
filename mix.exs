defmodule Discorelic.Mixfile do
  use Mix.Project

  def project do
    [
      app:               :discorelic,
      version:           "0.1.0",
      elixir:            "~> 1.2",
      description:       description,
      package:           package,
      build_embedded:    Mix.env == :prod,
      start_permanent:   Mix.env == :prod,
      elixirc_paths:     elixirc_paths(Mix.env),
      deps:              deps,
      test_coverage:     [ tool: ExCoveralls ],
      preferred_cli_env: [
        "coveralls":        :test,
        "coveralls.detail": :test,
        "coveralls.post":   :test,
        "coveralls.html":   :test,
        "coveralls.travis": :test,
      ],
    ]
  end

  def application do
    [
      mod: { Discorelic, [] },
      applications: [ :logger, :lhttpc ]
    ]
  end

  defp description do
    """
      Elixir implementation of the NewRelic intrumentation PaaS
    """
  end

  defp package do
    [
      maintainers: ["nogates"],
      licenses: ["MIT"],
      links: %{
        "GitHub" => "https://github.com/nogates/discorelic",
      }
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
