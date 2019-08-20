defmodule ClubHomepage.Mixfile do
  use Mix.Project

  def project do
    [app: :club_homepage,
     version: System.get_env("APP_VERSION") || "0.0.1",
     elixir: "~> 1.9",
     elixirc_paths: elixirc_paths(Mix.env),
     compilers: [:phoenix, :gettext] ++ Mix.compilers(), 
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     aliases: aliases(),
     deps: deps()]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [mod: {ClubHomepage.Application, []},
     #applications: [],
     extra_applications: [
       :tzdata,
       :phoenix, :phoenix_pubsub, :phoenix_html, :cowboy, :logger, :gettext,
       :phoenix_ecto, :postgrex, :comeonin, :geocoder, 
       :elixir_weather_data, :number, :bamboo, :bamboo_smtp, :arc_ecto
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
      #xxx{:ecto, "== 3.1.0", override: true},

      {:phoenix, "~> 1.4.9"},
      {:phoenix_pubsub, "~> 1.0"},
      {:ecto_sql, "~> 3.1"},
      {:phoenix_ecto, "~> 4.0"},
      {:postgrex, "~> 0.13"},
      {:phoenix_html, "~> 2.9"},
      {:phoenix_live_reload, "~> 1.0", only: :dev},
      {:dogma, "~> 0.0", only: :dev},
      {:plug_cowboy, "~> 2.1"},
      {:plug, "~> 1.8"},

      {:jason, "~> 1.1"},
      {:comeonin, "~> 4.1"},
      {:bcrypt_elixir, "~> 1.1"},
      #{:pbkdf2_elixir, "~> 0.12"},

      {:timex, "~> 3.6"},
      #xxx{:timex_ecto, "~> 3.4"},
      {:ex_machina, "~> 2.3", only: :test},
      {:gettext, "~> 0.11"},
      {:credo, "~> 0.10", only: [:dev, :test]},
      {:slugger, "~> 0.1"},
      {:json, "~> 0.3"},
      #{:ex_json_schema, "~> 0.6"},
      {:ex_json_schema, path: "/Users/sebastian/dev/elixir/ex_json_schema"},
      {:geocoder, "~> 0.6"},
      {:dialyxir, "~> 0.3", only: [:dev]},
      {:arc, "~> 0.11"},
      {:arc_ecto, "~> 0.11"},
      #{:mix_test_watch, "~> 0.2", only: :dev},

      #{:elixir_weather_data, path: "/home/franzi/dev/elixir/elixir_weather_data"},
      {:elixir_weather_data, "~> 0.2.6"},

      #{:ex_fussball_de_scraper, path: "/Users/sebastian/dev/elixir/ex_fussball_de_scraper"},
      {:ex_fussball_de_scraper, "~> 0.1"},
      {:httpoison, "~> 1.5", override: true},

      {:browser, "~> 0.4"},
      #{:browser, git: "git@github.com:the-guitarman/elixir-browser.git"},
      #{:browser, git: "https://github.com/the-guitarman/elixir-browser.git"},

      {:number, "~> 1.0"},
      {:bamboo, "~> 1.1"},
      {:bamboo_smtp, "~> 1.6"},

      {:icalendar, "~> 0.2"},

      {:distillery, "~> 2.0", runtime: false}, #run: mix do deps.get, compile
      #{:hackney, "== 1.8.0", override: true}
      {:hackney, "~> 1.15"}
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
     test: ["ecto.drop --quiet", "ecto.create --quiet", "ecto.migrate", "test"]]
  end
end
