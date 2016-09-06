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
    plug ClubHomepage.AuthByRole
    plug ClubHomepage.Locale
  end

  # pipeline :api do
  #   plug :accepts, ["json"]
  #   plug ClubHomepage.Auth, repo: ClubHomepage.Repo
  # end

  scope "/", ClubHomepage do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
    get "/chronicle.html", PageController, :chronicle
    get "/about-us.html", PageController, :about_us
    get "/registration-information.html", PageController, :registration_information
    get "/contact.html", PageController, :contact
    get "/sponsors.html", PageController, :sponsors

    resources "/matches", MatchController, only: [:show]
    get "/news", NewsController, :index
    resources "/users", UserController, only: [:new, :create]
    resources "/sessions", SessionController, only: [:new, :create, :delete]
    get "/teams/:slug", TeamController, :show, as: :team_page
    get "/teams/:slug/season/:season", TeamController, :show, as: :team_page_with_season
    get "/teams/:slug/images", TeamController, :show_images, as: :team_images_page
  end

  scope "/manage", ClubHomepage do
    pipe_through [:browser, :authenticate_user]
    
    get "/users/new", UserController, :new_unregistered, as: :unregistered_user
    post "/users", UserController, :create_unregistered, as: :unregistered_user
    resources "/users", UserController, only: [:index, :edit, :update, :delete], as: :managed_user

    resources "/addresses", AddressController, except: [:show]
    resources "/competitions", CompetitionController, except: [:show]
    resources "/matches", MatchController, expect: [:show]
    get "/matches/bulk/new", MatchController, :new_bulk, as: :matches
    post "/matches/bulk", MatchController, :create_bulk, as: :matches
    resources "/meeting_points", MeetingPointController, except: [:show]
    resources "/news", NewsController
    resources "/opponent_teams", OpponentTeamController, except: [:show]
    resources "/permalinks", PermalinkController
    resources "/seasons", SeasonController
    resources "/secrets", SecretController, only: [:index, :show, :new, :create, :delete]
    resources "/sponsor_images", SponsorImageController, except: [:show]
    resources "/teams", TeamController, only: [:index, :new, :create, :edit, :update, :delete]
    get "/teams/:id/chat", TeamController, :show_chat, as: :team_chat_page
    resources "/team_images", TeamImageController, except: [:show]
    resources "/text_pages", TextPageController, except: [:show, :new, :create, :delete]
  end

  # scope "/api", ClubHomepage do
  #   pipe_through :api

  #   scope "/manage", ClubHomepage do
  #     pipe_through :authenticate_user

  #   end
  # end
end
