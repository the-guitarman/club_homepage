defmodule ClubHomepage.Router do
  use ClubHomepage.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug ClubHomepage.Auth, repo: ClubHomepage.Repo
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", ClubHomepage do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
    get "/chronik.html", PageController, :chronicle
    get "/der-verein.html", PageController, :the_club
    get "/impressum.html", PageController, :impressum
    get "/kontakt.html", PageController, :contact
    get "/sponsoren.html", PageController, :sponsors

    resources "/users", UserController, only: [:new, :create]
    resources "/sessions", SessionController, only: [:new, :create, :delete]

    #resources "/teams", TeamController, only: [:show]
    get "/teams/:rewrite", TeamController, :show, as: :team
    #get "/seasons/:seasons/teams/:team"
    #get "/seasons/:seasons/teams/:team/matches"
    #get "/seasons/:seasons/teams/:team/matches/:match"
  end

  scope "/manage", ClubHomepage do
    pipe_through [:browser, :require_user]
    
    resources "/secrets", SecretController, only: [:new, :create, :show, :delete]
    resources "/users", UserController, only: [:index, :show, :edit, :update, :delete], as: :managed_user

    resources "/addresses", AddressController
    resources "/meeting_points", MeetingPointController
    
    resources "/teams", TeamController, only: [:index, :new, :create, :edit, :update, :delete]
    resources "/seasons", SeasonController
  end

  # Other scopes may use custom stacks.
  # scope "/api", ClubHomepage do
  #   pipe_through :api
  # end
end
