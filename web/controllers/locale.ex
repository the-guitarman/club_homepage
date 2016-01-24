defmodule ClubHomepage.Locale do
  import Plug.Conn

  def init(opts) do
    Keyword.fetch!(opts, :locale)
  end

  def call(conn, locale) do
    case conn.params["locale"] || get_session(conn, :locale) || locale do
      nil     -> conn
      locale  ->
        Gettext.put_locale(ClubHomepage.Gettext, locale)
        conn |> put_session(:locale, locale)
    end
  end
end
