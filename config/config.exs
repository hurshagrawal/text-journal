# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :journal,
  ecto_repos: [Journal.Repo]

# Configures the endpoint
config :journal, JournalWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "NTxq5AI3v0QaKrF71e3/uST9iar1z8c/yobpY86XaDYnv2GmOSzMg3pxL6INsm4w",
  render_errors: [view: JournalWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Journal.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :journal, Journal.Accounts.Guardian,
  issuer: "journal",
  secret_key: "b7z3rikSEyhWqnJb3pN2WsAImPRROJCENNxYTor7cK2Rg+N/9Ml+5rBvCn8KpI4e",
  allowed_algos: ["HS256"],
  ttl: {90, :days}

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
