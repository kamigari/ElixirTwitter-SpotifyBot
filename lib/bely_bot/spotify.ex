defmodule BelyBot.Spotify do
  @moduledoc """
  This module provides the functions required to query Spotify API
  """

  @doc """
  Function providing the desired imports
  """
  def controller do
    quote do
      import BelyBot.Spotify.Search
      import BelyBot.Spotify.Helpers
      import BelyBot.Spotify.Credentials
    end
  end

  @doc """
  Function provides the use macro
  """
  defmacro __using__(:controller = which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
