defmodule BelyBot.MixProject do
  use Mix.Project

  def project do
    [
      app: :bely_bot,
      version: "0.1.0",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :httpoison, :extwitter],
      mod: {BelyBot.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:oauther, "~> 1.1"},
      {:oauth2, "~> 0.9"},
      {:timex, "~> 3.1"},
      {:gen_stage, "~> 0.14"},
      {:poison, "~> 3.0"},
      {:httpoison, "~> 1.0"},
      {:extwitter, "~> 0.9.3"},
      {:distillery, "~> 2.0"}
    ]
  end
end
