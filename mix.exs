defmodule ClubHomepage.Mixfile do
  use Mix.Project

  def project do
    [app: :club_homepage,
     version: "0.0.1",
     elixir: "~> 1.0",
     elixirc_paths: elixirc_paths(Mix.env),
     compilers: [:phoenix, :gettext] ++ Mix.compilers, 
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     aliases: aliases,
     deps: deps]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [mod: {ClubHomepage, []},
     applications: [:tzdata, :phoenix, :phoenix_html, :cowboy, :logger, :gettext, 
      :phoenix_ecto, :sqlite_ecto, :comeonin, :geocoder]] 
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "web", "test/support"]
  defp elixirc_paths(_),     do: ["lib", "web"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [{:phoenix, "~> 1.1.4"},
     {:phoenix_ecto, "~> 2.0"},
     {:phoenix_html, "~> 2.3"},
     {:sqlite_ecto, "~> 1.0.1"},
     {:phoenix_live_reload, "~> 1.0", only: :dev},
     {:dogma, "~> 0.0", only: :dev},
     {:cowboy, "~> 1.0"},
     {:comeonin, "~> 2.0"},
     {:timex, "~> 0.19.0"},
     {:timex_ecto, "~> 0.7"},
     {:ex_machina, "~> 0.6"},
     {:gettext, "~> 0.9"},
     {:credo, "~> 0.2", only: [:dev, :test]},
     {:slugger, "~> 0.1.0"},
     {:json, "~> 0.3.0"},
     {:ex_json_schema, "~> 0.3.1"},
     {:geocoder, "~> 0.3"},
     {:geohash, github: "treetopllc/geohash"},
     {:dialyxir, "~> 0.3", only: [:dev]}#,
     #{:mix_test_watch, "~> 0.2.4", only: :dev}]
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
     "ecto.reset": ["ecto.drop", "ecto.setup"]]
  end
end
