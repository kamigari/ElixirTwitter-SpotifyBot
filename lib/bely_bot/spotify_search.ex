defmodule BelyBot.Spotify.Search do
  use HTTPoison.Base
  import BelyBot.Spotify.Helpers

  @moduledoc """
  This module provides functions to call Spotify search API endpoint
  """

  _ = """
    Function provides the spotify base url endpoint
  """

  defp api_url, do: "https://api.spotify.com"

  _ = """
  Function provides the search endpoint
  """

  defp search_url, do: "/v1/search"

  _ = """
  Function provides the search body params
  """

  defp search_body(search, type, market \\ "ES", limit \\ 10, offset \\ 0),
    do:
      URI.encode_query(%{
        "q" => search,
        "type" => type,
        "market" => market,
        "limit" => limit,
        "offset" => offset
      })

  @doc """
  Function searches the requested song in Spotify API search endpoint
  """
  def search(song, type \\ "track") do
    case HTTPoison.get(
           "#{api_url()}#{search_url()}?#{search_body(song, type)}",
           request_headers()
         ) do
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

  def search(song, type, market, limit, offset) do
    case HTTPoison.get(
           "#{api_url()}#{search_url()}?#{search_body(song, type, market, limit, offset)}",
           request_headers()
         ) do
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
