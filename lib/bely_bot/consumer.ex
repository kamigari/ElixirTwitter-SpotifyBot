defmodule BelyBot.Consumer do
  use GenStage, restart: :transient, shutdown: 60_000
  use BelyBot.Spotify, :controller
  require Logger

  @moduledoc """
  This module consumes the tweets for the service
  """

  @doc """
  Starts the GenStage for consuming the tweets
  """
  def start_link do
    GenStage.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @doc """
  Callback function when the GenStage is started
  """
  def init(state) do
    {:consumer, state, subscribe_to: [BelyBot.Producer]}
  end

  @doc """
  Callback function for the consumer. Tweets Spotify song
  """
  def handle_events(events, _from, state) do
    for event <- events do
      {self(), event, state} |> IO.inspect()

      cond do
        String.contains?(event.text, "song") ->
          cmd_song(event)
      end
    end

    {:noreply, [], state}
  end

  _ = """
  Searches for the song in Spotify API
  """

  defp cmd_song(tweet) do
    [_text | [song_untrim]] = String.split(tweet.text, "song")

    case search(String.trim(song_untrim), "track") do
      {:ok, map} ->
        song_url = get_song({:ok, map |> Map.get("tracks") |> Map.get("items") |> List.first()})

        ExTwitter.update(
          "@#{tweet.user.screen_name}\n#{song_url}",
          in_reply_to_status_id: tweet.id
        )
        |> IO.inspect()

      {:error, error} ->
        Logger.debug(error)
    end
  end

  _ = """
  Function parsing the Spotify object
  """

  defp get_song({:ok, track}), do: track |> Map.get("external_urls") |> Map.get("spotify")
end
