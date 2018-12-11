# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :blockchain_analyser,
  ecto_repos: [BlockchainAnalyser.Repo]

# Configures the endpoint
config :blockchain_analyser, BlockchainAnalyserWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "QWZE1j6A3OBVX+aVrtqty+I7ZOktc5YFmRP9ot3HYvMMZ/uLLgcb+TmDdVDMT1FR",
  render_errors: [view: BlockchainAnalyserWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: BlockchainAnalyser.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
