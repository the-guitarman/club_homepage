defmodule ClubHomepage.AuthByRole do
  import Phoenix.Controller
  import Plug.Conn

  alias ClubHomepage.Router.Helpers
  alias ClubHomepage.UserRole

  def init(opts) do
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

  def is_team_editor?(conn, _options) do
    has_role?(conn, "team-editor")
  end

  def is_text_page_editor?(conn, _options) do
    has_role?(conn, "text-page-editor")
  end

  def is_user_editor?(conn, _options) do
    has_role?(conn, "user-editor")
  end

  def has_role_from_list?(conn, options) do
    roles = Keyword.fetch!(options, :roles)
    case Enum.any?(roles, fn(role) -> UserRole.has_role?(conn, role) end) do
      true  -> conn
      false -> halt_request(conn)
    end
  end

  def has_role?(conn, roles) when is_list(roles) do
    Enum.any?(roles, fn(role) -> has_role?(conn, role) end)
  end
  def has_role?(conn, role) do
    if UserRole.has_role?(conn, role) || UserRole.has_role?(conn, "administrator") do
      conn
    else
      halt_request(conn)
    end
  end

  defp halt_request(conn) do
    conn
    |> put_flash(:error, "You are not authorized!")
    |> redirect(to: Helpers.page_path(conn, :index))
    |> halt()
  end
end
