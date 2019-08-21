# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :club_homepage,
  ecto_repos: [ClubHomepage.Repo]

# Configures the endpoint
config :club_homepage, ClubHomepageWeb.Endpoint,
  url: [host: "localhost"],
#  root: Path.dirname(__DIR__),
  secret_key_base: "/FTNk/qEtZWOZhuUwYiry4YC9G5qDxjK/DSmSzkEiuH7kzG5AxheGYE4BPEA3H9X",
  render_errors: [view: ClubHomepageWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: ClubHomepage.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logge
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :club_homepage, ClubHomepageWeb.Gettext,
  default_locale: "de",
  locales: ~w(en de)


# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
if System.get_env("TRAVIS") do
  import_config "#{Mix.env}.exs.template"
else
  import_config "#{Mix.env}.exs"
end

## Configure phoenix generators
#config :phoenix, :generators,
#  migration: true,
#  binary_id: false

config :phoenix, :filter_parameters, 
  ["password", "password_hash", "secret"]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :geocoder, Geocoder.Worker, [size: 4, max_overflow: 2]
config :geocoder, Geocoder.Store, [precision: 4]

config :club_homepage, :match,
  failure_reasons: ["aborted", "failed", "canceled", "team_missed"]

# Import specific club homepage config.
if System.get_env("TRAVIS") do
  import_config "club_homepage.exs.template"
else
  import_config "club_homepage.exs"
end

config :arc,
  storage: Arc.Storage.Local
#  storage: Arc.Storage.S3, # or Arc.Storage.Local
#  bucket: {:system, "AWS_S3_BUCKET"} # if using Amazon S3
