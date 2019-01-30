defmodule BelyBot.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  require Logger

  def start(_type, _args) do
    # List all child processes to be supervised
    import Supervisor.Spec, warn: false

    children = [
      # Starts a worker by calling: BelyBot.Worker.start_link(arg)
      # {BelyBot.Worker, arg},
      BelyBot.Spotify.Credentials,
      worker(BelyBot.Producer, []),
      worker(BelyBot.Consumer, [])
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: BelyBot.Supervisor]

    case Supervisor.start_link(children, opts) do
      {:ok, pid} ->
        Logger.info("Starting BelyBot")
        {:ok, pid}

      {:error, {:already_started, pid}} ->
        Logger.error("Error already started BelyBot: #{pid}")
        {:error, {:already_started, pid}}

      {:error, {:shutdown, reason}} ->
        Logger.error("Error shutting down BelyBot: #{reason}")
        {:error, {:shutdown, reason}}

      {:error, reason} ->
        Logger.error("Error starting BelyBot: #{reason}")
        {:error, reason}
    end
  end
end
