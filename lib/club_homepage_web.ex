defmodule ClubHomepageWeb do
  @moduledoc """
  A module that keeps using definitions for controllers,
  views and so on.

  This can be used in your application as:

      use ClubHomepageWeb, :controller
      use ClubHomepageWeb, :view

  The definitions below will be executed for every view,
  controller, etc, so keep them short and clean, focused
  on imports, uses and aliases.

  Do NOT define functions inside the quoted expressions
  below.
  """

  def model do
    quote do
      use Ecto.Schema

      import Ecto
      import Ecto.Changeset
      import Ecto.Query

      import ClubHomepageWeb.Gettext
    end
  end

  def club_homepage_model do
    quote do
      alias ClubHomepage.Repo

      def get_by(%{} = find_by_attributes) do
        Repo.get_by(__MODULE__, find_by_attributes)
      end

      def find_or_create(%{} = attributes) do
        case get_by(attributes) do
          nil ->
            __MODULE__.changeset(__MODULE__.__struct__, attributes)
            |> Repo.insert
          record ->
            {:ok, record}
        end
      end

      def create_or_update(%{} = find_by_attributes, %{} = new_attributes) do
        case get_by(find_by_attributes) do
          nil ->
            attributes = Map.merge(new_attributes, find_by_attributes)
            __MODULE__.changeset(__MODULE__.__struct__, attributes)
            |> Repo.insert
          record ->
            record
            |> __MODULE__.changeset(new_attributes)
            |> Repo.update
        end
      end
    end
  end

  def controller do
    quote do
      use Phoenix.Controller, namespace: ClubHomepageWeb

      alias ClubHomepage.Repo
#      import Ecto.Schema
      import Ecto
      import Ecto.Query

      alias ClubHomepageWeb.Router.Helpers, as: Routes
      #import ClubHomepageWeb.Router.Helpers

      import ClubHomepageWeb.Gettext
      import ClubHomepageWeb.Localization

      import ClubHomepage.Extension.Controller
      import ClubHomepage.Extension.Common, only: [failure_reasons: 0, internal_user_name: 1, get_config: 1]
      import ClubHomepage.Extension.CommonSeason
      import ClubHomepage.Extension.CommonTimex
      import ClubHomepageWeb.Auth, only: [authenticate_user: 2, require_no_user: 2, current_user: 1, logged_in?: 1, logged_in?: 2]
      import ClubHomepageWeb.AuthByRole, only: [has_role: 2, is_administrator: 2, is_match_editor: 2, is_member: 2, is_news_editor: 2, is_player: 2, is_team_editor: 2, is_text_page_editor: 2, is_user_editor: 2, has_role_from_list: 2]
      import ClubHomepageWeb.AuthForPaymentList, only: [authenticate_payment_list_owner_or_deputy: 2]

      import ClubHomepageWeb.SEO.Plug
    end
  end

  def view do
    quote do
      use Phoenix.View,
        root: "lib/club_homepage_web/templates",
        namespace: ClubHomepageWeb
        #pattern: "**/*.eex"

      # Import convenience functions from controllers
      import Phoenix.Controller, only: [get_csrf_token: 0, get_flash: 2, view_module: 1, action_name: 1, controller_module: 1]

      # Use all HTML functionality (forms, tags, etc)
      use Phoenix.HTML

      alias ClubHomepageWeb.Router.Helpers, as: Routes
      #import ClubHomepageWeb.Router.Helpers

      import ClubHomepageWeb.ErrorHelpers
      import ClubHomepageWeb.Gettext
      import ClubHomepageWeb.Localization

      import ClubHomepage.Extension.View
      import ClubHomepage.Extension.Common, only: [failure_reasons: 0, internal_user_name: 1, user_name: 1, get_config: 1]
      import ClubHomepage.Extension.CommonSeason
      import ClubHomepage.Extension.CommonTimex
      import ClubHomepageWeb.Auth, only: [logged_in?: 1, current_user: 1, current_user_id: 1]
      import ClubHomepageWeb.UserRole, only: [has_role?: 2]
    end
  end

  def router do
    quote do
      use Phoenix.Router

      import ClubHomepageWeb.Auth, only: [authenticate_user: 2, current_user: 1]
      import ClubHomepageWeb.AuthByRole, only: [has_role: 2, is_administrator: 2, is_match_editor: 2, is_member: 2, is_news_editor: 2, is_player: 2, is_team_editor: 2, is_text_page_editor: 2, is_user_editor: 2]
    end
  end

  def channel do
    quote do
      use Phoenix.Channel

      alias ClubHomepage.Repo
#      import Ecto.Schema
      import Ecto
      import Ecto.Query
      import ClubHomepageWeb.Gettext
      import ClubHomepageWeb.Localization

      import ClubHomepage.Extension.Common, only: [internal_user_name: 1]
    end
  end
  
  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
