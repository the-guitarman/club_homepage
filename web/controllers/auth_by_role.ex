defmodule ClubHomepage.AuthByRole do
  import Phoenix.Controller
  import Plug.Conn

  alias ClubHomepage.Router.Helpers
  alias ClubHomepage.UserRole

  def init(_opts) do
    nil
  end

  def call(conn, _nil) do
    conn
  end

  def is_administrator?(conn, _options) do
    has_role?(conn, "administrator")
  end

  def is_match_editor?(conn, _options) do
    has_role?(conn, "match-editor")
  end

  def is_member?(conn, _options) do
    has_role?(conn, "member")
  end

  def is_news_editor?(conn, _options) do
    has_role?(conn, "news-editor")
  end

  def is_player?(conn, _options) do
    has_role?(conn, "player")
  end

  def is_text_page_editor?(conn, _options) do
    has_role?(conn, "text-page-editor")
  end

  def is_trainer?(conn, _options) do
    has_role?(conn, "trainer")
  end

  def is_user_editor?(conn, _options) do
    has_role?(conn, "user-editor")
  end

  defp has_role?(conn, role) do
    if UserRole.has_role?(conn, role) || UserRole.has_role?(conn, "administrator") do
      conn
    else
      conn
      |> put_flash(:error, "You are not authorized!")
      |> redirect(to: Helpers.page_path(conn, :index))
      |> halt()
    end
  end
end
