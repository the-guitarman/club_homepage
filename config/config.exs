# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# Configures the endpoint
config :club_homepage, ClubHomepage.Endpoint,
  url: [host: "localhost"],
  root: Path.dirname(__DIR__),
  secret_key_base: "/FTNk/qEtZWOZhuUwYiry4YC9G5qDxjK/DSmSzkEiuH7kzG5AxheGYE4BPEA3H9X",
  render_errors: [accepts: ~w(html json)],
  pubsub: [name: ClubHomepage.PubSub,
           adapter: Phoenix.PubSub.PG2],
  locale: "de"

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"

# Configure phoenix generators
config :phoenix, :generators,
  migration: true,
  binary_id: false

config :phoenix, :filter_parameters, 
  ["password", "password_hash", "secret"]

config :geocoder, Geocoder.Worker, [size: 4, max_overflow: 2]
config :geocoder, Geocoder.Store, [precision: 4]

config :club_homepage, :match, 
  failure_reasons: ["failed", "canceled", "team_missed"]
