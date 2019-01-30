defmodule BelyBot.Spotify.Credentials do
  use GenServer, restart: :transient, shutdown: 30_000
  require Logger

  @moduledoc """
  This module provides a storage for Spotify credentials and the DateTime
  """

  _ = """
  Function to retrieve from env client_id
  """

  defp client_id, do: Application.get_env(:bely_bot, :client_id)

  _ = """
  Function to retrieve from env secret_key
  """

  defp secret_key, do: Application.get_env(:bely_bot, :secret_key)

  _ = """
  Function to encode in base64 the required credentials
  """

  defp credentials, do: "#{client_id()}:#{secret_key()}" |> :base64.encode()

  _ = """
  Function to sustain Spotify token url
  """

  defp token_url, do: "https://accounts.spotify.com/api/token"

  @doc """
  Starts the GenServer
  """
  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  @doc """
  Callback function when the GenServer is started
  """
  @impl true
  def init(store) do
    set_credentials()
    {:ok, store}
  end

  @doc """
  Function casting a item into the GenServer
  """
  def put(item), do: GenServer.cast(__MODULE__, {:put, item})

  @doc """
  Function calling the credentials from the GenServer
  """
  def get_credentials, do: GenServer.call(__MODULE__, :get_credentials)

  @doc """
  Function calling the DateTime from the GenServer
  """
  def get_datetime, do: GenServer.call(__MODULE__, :get_datetime)

  @doc """
  Callback for the GenServer to handle the cast to put an item into the map of the store
  """
  @impl true
  def handle_cast({:put, item}, store) do
    {k, v} = item
    {:noreply, Map.put(store, k, v)}
  end

  @doc """
  Callback for the GenServer to handle the calling for the credentials
  """
  @impl true
  def handle_call(:get_credentials, _from, store) do
    {:reply, Map.get(store, :credentials), store}
  end

  @doc """
  Callback for the GenServer to handle the calling for the DateTime
  """
  @impl true
  def handle_call(:get_datetime, _from, store) do
    {:reply, Map.get(store, :datetime), store}
  end

  @doc """
  Callback function to refresh the token and DateTime
  """
  @impl true
  def handle_info(:refresh, store) do
    new_store =
      case get_token() do
        {:ok, creds} ->
          token = creds |> Map.get("access_token")

          Map.put(store, :credentials, token)
          |> Map.put(:datetime, DateTime.utc_now())

        {:error, error} ->
          Logger.debug(error)
          store
      end

    schedule_refresh_credentials()
    {:noreply, new_store}
  end

  _ = """
  Function to send the message to refresh
  """

  defp set_credentials, do: Process.send(self(), :refresh, [])

  _ = """
  Function to schedule a refresh
  """

  defp schedule_refresh_credentials, do: Process.send_after(self(), :refresh, 3_600_000)

  _ = """
  Function to stablish the Auth headers
  """

  defp token_headers,
    do: [
      {"Authorization", "Basic #{credentials()}"},
      {"Content-Type", "application/x-www-form-urlencoded"}
    ]

  _ = """
  Function to stablish the Auth body params
  """

  defp token_body,
    do:
      URI.encode_query(%{
        "grant_type" => "client_credentials"
      })

  _ = """
  Function to retrieve a Spotify token from credentials
  """

  defp get_token do
    case HTTPoison.post("#{token_url()}", token_body(), token_headers()) do
      {:ok,
       %HTTPoison.Response{body: body, headers: _headers, request_url: _url, status_code: 200}} ->
        case Poison.decode(body) do
          {:ok, decoded} -> {:ok, decoded}
          {:error, error} -> {:error, error}
        end

      {:ok,
       %HTTPoison.Response{
         body: _body,
         headers: _headers,
         request_url: _url,
         status_code: status_code
       }} ->
        {:error, status_code}

      {:ok, %HTTPoison.AsyncResponse{id: id}} ->
        {:error, id}

      {:error, %HTTPoison.Error{id: exception, reason: reason}} ->
        {:error, {exception, reason}}
    end
  end
end
