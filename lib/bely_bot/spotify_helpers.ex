defmodule BelyBot.Spotify.Helpers do
  import BelyBot.Spotify.Credentials

  @moduledoc """
  This module provides functions required by other modules
  """

  @doc """
  Function provides the request headers
  """
  def request_headers,
    do: [
      {"Authorization", "Bearer #{credentials_polling(get_credentials())}"}
    ]

  @doc """
  Function to poll the credentials from the GenServer
  """
  def credentials_polling(nil) do
    credentials_polling(get_credentials())
  end

  def credentials_polling(credentials), do: credentials
end
