defmodule ClubHomepage.Locale do
  import Plug.Conn

  def init(opts) do
    opts
  end

  def call(conn, _) do
    locale = Application.get_env(:club_homepage, ClubHomepage.Web.Endpoint)[:locale]
    case conn.params["locale"] || get_session(conn, :locale) || locale do
      nil     -> conn
      locale  ->
        Gettext.put_locale(ClubHomepage.Web.Gettext, locale)
        conn |> put_session(:locale, locale)
    end
  end
end
