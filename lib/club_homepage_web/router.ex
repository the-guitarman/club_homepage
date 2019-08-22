defmodule ClubHomepageWeb.Router do
  use ClubHomepageWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug ClubHomepageWeb.PermalinkRedirection, path_prefixes: [:teams]
    plug ClubHomepageWeb.Auth, repo: ClubHomepage.Repo
    plug ClubHomepageWeb.AuthByRole
    plug ClubHomepageWeb.Locale
    plug ClubHomepageWeb.WeatherData
    plug ClubHomepageWeb.MemberBirthday
    plug ClubHomepageWeb.MyPaymentLists
    # plug ClubHomepageWeb.AuthForPaymentList
    # plug ClubHomepageWeb.JavascriptLocalization
  end

  # pipeline :api do
  #   plug :accepts, ["json"]
  #   plug ClubHomepageWeb.Auth, repo: ClubHomepage.Repo
  # end

  scope "/", ClubHomepageWeb do
    pipe_through [:browser] # Use the default browser stack

    get "/", PageController, :index
    get "/chronicle.html", PageController, :chronicle
    get "/about-us.html", PageController, :about_us
    get "/registration-information.html", PageController, :registration_information
    get "/contact.html", PageController, :contact
    get "/sponsors.html", PageController, :sponsors

    resources "/matches", MatchController, only: [:show]
    get "/manage/matches/new/:parent_id", MatchController, :new_successor_match, as: :match
    get "/news", NewsController, :index
    resources "/users", UserController, only: [:new, :create]
    get "/users/forgot-password", UserController, :forgot_password_step_1, as: :forgot_password
    post "/users/forgot-password", UserController, :forgot_password_step_2, as: :forgot_password
    get "/users/change-password/:id/:token", UserController, :change_password, as: :change_password
    put "/users/reset-password", UserController, :reset_password, as: :reset_password
    resources "/sessions", SessionController, only: [:new, :create, :delete], singleton: true
    get "/teams/:slug", TeamController, :show, as: :team_page
    get "/teams/:slug/season/:season/download-ical", TeamController, :download_ical, as: :team_matches_download
    get "/teams/:slug/season/:season", TeamController, :show, as: :team_page_with_season
    get "/teams/:slug/images", TeamController, :show_images, as: :team_images_page
  end

  scope "/manage", ClubHomepageWeb do
    pipe_through [:browser, :authenticate_user]
    
    get "/users/new", UserController, :new_unregistered, as: :unregistered_user
    post "/users", UserController, :create_unregistered, as: :unregistered_user
    resources "/users", UserController, only: [:index, :show, :edit, :update, :delete], as: :managed_user do
      get "/edit-restricted", UserController, :edit_restricted, as: :edit_restricted
      put "/edit-restricted", UserController, :update_restricted, as: :edit_restricted
      delete "/deactivate-account", UserController, :deactivate_account, as: :deactivate_account
    end

    resources "/addresses", AddressController, except: [:show]
    resources "/competitions", CompetitionController, except: [:show]
    resources "/matches", MatchController, expect: [:show]
    get "/matches/bulk/new", MatchController, :new_bulk, as: :matches
    post "/matches/bulk", MatchController, :create_bulk, as: :matches
    resources "/meeting-points", MeetingPointController, except: [:show]
    resources "/news", NewsController
    resources "/opponent-teams", OpponentTeamController, except: [:show]
    resources "/payment-lists", PaymentListController do
      resources "/debitors", PaymentListDebitorController, only: [:show, :create, :edit, :update, :delete], as: "debitor"
    end
    resources "/permalinks", PermalinkController
    resources "/seasons", SeasonController
    resources "/secrets", SecretController, only: [:index, :show, :new, :create, :delete]
    resources "/sponsor-images", SponsorImageController, except: [:show]
    resources "/teams", TeamController, only: [:index, :new, :create, :edit, :update, :delete]
    get "/teams/:id/chat", TeamController, :show_chat, as: :team_chat_page
    resources "/team-chat-messages", TeamChatMessageController, only: [:index, :delete]
    resources "/team-images", TeamImageController, except: [:show]
    resources "/text-pages", TextPageController, except: [:show, :new, :create, :delete]
    get "/teams/:slug/standard-players", TeamController, :edit_standard_players, as: :team_standard_players
  end

  # scope "/api", ClubHomepageWeb do
  #   pipe_through :api

  #   scope "/manage", ClubHomepageWeb do
  #     pipe_through :authenticate_user

  #   end
  # end
end
