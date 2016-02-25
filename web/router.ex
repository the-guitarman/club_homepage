defmodule ClubHomepage.Router do
  use ClubHomepage.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug ClubHomepage.PermalinkRedirection, path_prefixes: [:teams]
    plug ClubHomepage.Auth, repo: ClubHomepage.Repo
    plug ClubHomepage.Locale
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug ClubHomepage.Auth, repo: ClubHomepage.Repo
  end

  scope "/", ClubHomepage do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
    get "/chronicle.html", PageController, :chronicle
    get "/about-us.html", PageController, :about_us
    get "/registration-information.html", PageController, :registration_information
    get "/contact.html", PageController, :contact
    get "/sponsors.html", PageController, :sponsors

    get "/news", NewsController, :index
    resources "/users", UserController, only: [:new, :create]
    resources "/sessions", SessionController, only: [:new, :create, :delete]
    get "/teams/:slug", TeamController, :team_page, as: :team_page
    get "/teams/:slug/season/:season", TeamController, :team_page, as: :team_page_with_season
    ##resources "/teams", TeamController, only: [:show]
    ##get "/seasons/:seasons/teams/:team"
    ##get "/seasons/:seasons/teams/:team/matches"
    ##get "/seasons/:seasons/teams/:team/matches/:match"
  end

  scope "/manage", ClubHomepage do
    pipe_through [:browser, :authenticate_user]
    
    resources "/secrets", SecretController, only: [:new, :create, :show, :delete]
    get "/users/new", UserController, :new_unregistered, as: :unregistered_user
    post "/users", UserController, :create_unregistered, as: :unregistered_user
    resources "/users", UserController, only: [:index, :show, :edit, :update, :delete], as: :managed_user

    resources "/addresses", AddressController
    resources "/matches", MatchController
    resources "/meeting_points", MeetingPointController
    resources "/news", NewsController
    resources "/opponent_teams", OpponentTeamController
    resources "/permalinks", PermalinkController
    resources "/teams", TeamController, only: [:index, :new, :show, :create, :edit, :update, :delete]
    resources "/seasons", SeasonController
  end

  # scope "/api", ClubHomepage do
  #   pipe_through :api

  #   scope "/manage", ClubHomepage do
  #     pipe_through :authenticate_user

  #   end
  # end
end
