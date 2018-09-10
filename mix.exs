defmodule ClubHomepage.Mixfile do
  use Mix.Project

  def project do
    [app: :club_homepage,
     version: "0.2.0",
     elixir: "~> 1.6",
     elixirc_paths: elixirc_paths(Mix.env),
     compilers: [:phoenix, :gettext] ++ Mix.compilers, 
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     aliases: aliases(),
     deps: deps()]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [mod: {ClubHomepage, []},
     #applications: [],
     extra_applications: [
       :tzdata,
       :phoenix, :phoenix_pubsub, :phoenix_html, :cowboy, :logger, :gettext,
       :phoenix_ecto, :postgrex, :comeonin, :geocoder, 
       :elixir_weather_data, :number, :bamboo, :arc_ecto
     ],
     included_applications: [:towel]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_),     do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
     {:phoenix, "~> 1.3.0"},
     {:phoenix_pubsub, "~> 1.0"},
     {:phoenix_ecto, "~> 3.2"},
     {:postgrex, ">= 0.0.0"},
     {:phoenix_html, "~> 2.9"},
     {:phoenix_live_reload, "~> 1.0", only: :dev},
     {:dogma, "~> 0.0", only: :dev},
     {:cowboy, "~> 1.0"},
     {:comeonin, "~> 2.0"},
     {:timex, "~> 3.3"},
     {:timex_ecto, "~> 3.3"},
     {:ex_machina, "~> 1.0", only: :test},
     {:gettext, "~> 0.11"},
     {:credo, "~> 0.2", only: [:dev, :test]},
     {:slugger, "~> 0.1.0"},
     {:json, "~> 0.3.0"},
     {:ex_json_schema, "~> 0.3.1"},
     {:geocoder, "~> 0.6.2"},
     {:dialyxir, "~> 0.3", only: [:dev]},
     {:arc, "~> 0.8.0"},
     {:arc_ecto, "~> 0.7.0"},
     #{:mix_test_watch, "~> 0.2.4", only: :dev},

     #{:elixir_weather_data, path: "/Users/sebastian/dev/elixir/elixir_weather_data"},
     {:elixir_weather_data, "~> 0.2.2"},

     {:ex_fussball_de_scraper, path: "/Users/sebastian/dev/elixir/ex_fussball_de_scraper"},
     #{:ex_fussball_de_scraper, "~> 0.1"},
     {:browser, "~> 0.4"},

     {:number, "~> 0.5.1"},
     {:bamboo, "~> 0.7"},
     {:bamboo_smtp, "~> 1.2.1"},

     {:icalendar, "~> 0.2.1"},

     {:distillery, "~> 1.5.3", runtime: false}, #run: mix do deps.get, compile
     {:hackney, "== 1.8.0", override: true}
    ]
  end

  # Aliases are shortcut or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    ["ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
     "ecto.reset": ["ecto.drop", "ecto.setup"],
     "test": ["ecto.drop --quiet", "ecto.create --quiet", "ecto.migrate", "test"]]
  end
end
