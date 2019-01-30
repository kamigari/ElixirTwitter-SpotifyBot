defmodule BelyBot.Producer do
  use GenStage, restart: :transient, shutdown: 60_000
  use BelyBot.Spotify, :controller

  @moduledoc """
  This module produces the tweets for the service
  """

  _ = """
  Function retrieves the artist from env
  """

  defp artist, do: Application.get_env(:bely_bot, :artist)

  _ = """
  Function retrieves the bot from env
  """

  defp bot, do: Application.get_env(:bely_bot, :bot)

  @doc """
  Starts the GenStage
  """
  def start_link(init \\ 0) do
    GenStage.start_link(__MODULE__, init, name: __MODULE__)
  end

  @doc """
  Callback function when the GenStage is started
  """
  def init(state), do: {:producer, state}

  @doc """
  Callback function for the producer. Polling for events
  """
  def handle_demand(demand, state) do
    {:noreply, get_mentions(), state + demand}
  end

  _ = """
  Polling function to get from the GenServer the DateTime
  """

  defp datetime_polling(nil) do
    datetime_polling(get_datetime())
  end

  defp datetime_polling(datetime), do: datetime

  _ = """
  Function to get twitter mentions containing the command "!bely"
  """

  defp get_mentions() do
    ExTwitter.mentions_timeline()
    |> Enum.filter(fn tweet ->
      String.contains?(tweet.text, artist()) or String.contains?(tweet.text, bot())
    end)
    |> compare_dates_of_tweets()
    |> tweets_polling()
  end

  _ = """
  Polling function for the twitter mentions
  """

  defp tweets_polling([]) do
    :timer.sleep(300_000)
    get_mentions()
  end

  defp tweets_polling(tweets), do: tweets

  _ = """
  Function to equiparate DateTimes from GenServer and the tweet
  """

  defp compare_dates_of_tweets(list) do
    list
    |> Enum.filter(fn tweet ->
      if NaiveDateTime.compare(
           get_tweet_date(tweet),
           get_creds_date()
         ) == :gt do
        tweet
      end
    end)
  end

  _ = """
  Function to parse the DateTime from the GenServer
  """

  defp get_creds_date() do
    [creds_date | _tail] =
      datetime_polling(get_datetime())
      |> DateTime.to_string()
      |> String.split(".")

    creds_date
    |> Timex.parse!("%Y-%m-%d %H:%M:%S", :strftime)
  end

  _ = """
  Function to parse the DateTime from the tweet
  """

  defp get_tweet_date(tweet) do
    [tweet_date | _tail] =
      tweet.created_at
      |> Timex.parse!("%a %b %d %H:%M:%S %z %Y", :strftime)
      |> DateTime.to_string()
      |> String.split("+")

    tweet_date
    |> Timex.parse!("%Y-%m-%d %H:%M:%S", :strftime)
  end
end
