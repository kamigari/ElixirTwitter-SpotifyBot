# BelyBot

This is a practise project to get more knowledge from GenServer and GenStage from Elixir.

## Installation

  * Install dependencies and compile them with `mix do deps.get, compile`
  * Run without deployment:
  ```
  $ mix run --no-halt
  or
  $ iex -S mix
  ```
  * Run with deployment:
  ```
  $ mix release.init
  $ mix release
  To start the release you have built, you can use one of the following tasks:
  # start a shell, like 'iex -S mix'
  $ _build/dev/rel/bely_bot/bin/bely_bot.sh console
  # start in the foreground, like 'mix run --no-halt'
  $ _build/dev/rel/bely_bot/bin/bely_bot.sh foreground
  # start in the background, must be stopped with the 'stop' command
  $ _build/dev/rel/bely_bot/bin/bely_bot.sh start
  If you started a release elsewhere, and wish to connect to it:
  # connects a local shell to the running node
  $ _build/dev/rel/bely_bot/bin/bely_bot.sh remote_console
  # connects directly to the running node's console
  $ _build/dev/rel/bely_bot/bin/bely_bot.sh attach
  For a complete listing of commands and their use:
  $ _build/dev/rel/bely_bot/bin/bely_bot.sh help
  ```

#### Configuration

In `config/config.exs`, change to your bot name and Artist:

```
config :bely_bot,
  artist: "Artist",
  bot: "!bot"
```  

Or manually at runtime:

```
elixir
  BelyBot.Application.configure([artist: "", bot: ""])
```

In `config/spotify.secret.exs`, change to your spotify keys:

```
use Mix.Config

config :bely_bot,
  client_id: "{client_id}",
  secret_key: "{secret_key}"
```  

Or manually at runtime:

```
elixir
  BelyBot.Application.configure([client_id: "", secret_key: ""])
```

In `config/dev.secret.exs`, change to your twitter keys:

```
use Mix.Config

config :extwitter, :oauth,
  consumer_key: "{consumer_key}",
  consumer_secret: "{consumer_secret}",
  access_token: "{access_token}",
  access_token_secret: "{access_token_secret}"
```  

In `config/prod.secret.exs`, change to your twitter keys:

```
use Mix.Config

config :extwitter, :oauth,
  consumer_key: "{consumer_key}",
  consumer_secret: "{consumer_secret}",
  access_token: "{access_token}",
  access_token_secret: "{access_token_secret}"
```  

#### Functionalities

* This bot just polls from the Twitter credentials provided the mentions. If a tweet matches the pattern: "@bot song ..." or "@artist song ..." it will query the Spotify API to retrieve the url song and tweeted as a response to the tweet from the mentions timeline.

* TODO: Support other markets from Spotify than spanish songs.
It will still retrieve the first Spotify song retrieved by
the query even its still not a match.

#### Persistence

The data persistence its held in the GenServer. The GenServer holds the Spotify token retrieved from the credentials and the DateTime when its started. The decision to choose GenServer over Agent its the polling from Spotify credentials to get a new token when its expired.

## Prerequisites

  * To run this project you need:
    * Erlang: The programming language http://www.erlang.org/
    * Elixir: The programming language https://elixir-lang.org/

## Built within

* Elixir: The programming language https://elixir-lang.org/

## Authors

* **Alberto Revuelta Arribas** - *initial work* [kamigari](https://github.com/kamigari)

## License

* This project is licensed under the License - see the [LICENSE.md](LICENSE.md) file for details.
