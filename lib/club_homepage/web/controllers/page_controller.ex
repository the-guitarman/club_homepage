defmodule ClubHomepage.Web.PageController do
  use ClubHomepage.Web, :controller

  alias ClubHomepage.Repo
  alias ClubHomepage.Match
  alias ClubHomepage.News
  alias ClubHomepage.Team
  alias ClubHomepage.TextPage

  plug :put_seo

  def index(conn, _params) do
    news  = Repo.all(news_query(conn))
    teams = Repo.all(from(t in Team, order_by: [asc: t.inserted_at]))
    start_at = to_timex_ecto_datetime(Timex.local)

    matches_query = from(m in Match, preload: [:competition, :team, :opponent_team], limit: 1)
    next_matches_query = from(m in matches_query, where: m.start_at > ^start_at, order_by: [asc: m.start_at])
    next_matches =
      find_next_team_matches(next_matches_query, teams)
      |> Enum.reject(fn(x) -> x == nil end)
      |> Enum.sort(fn(x, y) -> DateTime.compare(x.start_at, y.start_at) == :lt end)
    last_matches_query = from(m in matches_query, where: m.start_at < ^start_at, order_by: [desc: m.start_at])
    last_matches =
      find_next_team_matches(last_matches_query, teams)
      |> Enum.reject(fn(x) -> x == nil end)
      |> Enum.sort(fn(x, y) -> DateTime.compare(x.start_at, y.start_at) == :gt end)
    {_, weather_data} = ClubHomepage.Web.WeatherData.get
    render conn, "index.html", teams: teams, news: news, next_matches: next_matches, last_matches: last_matches, weather_data: weather_data
  end

  def about_us(conn, _params) do
    render conn, "about_us.html", page_content: find_or_create_text_page(conn.request_path)
  end

  def chronicle(conn, _params) do
    render conn, "chronicle.html", page_content: find_or_create_text_page(conn.request_path)
  end

  def contact(conn, _params) do
    render conn, "contact.html", page_content: find_or_create_text_page(conn.request_path)
  end

  def registration_information(conn, _params) do
    render conn, "registration_information.html", page_content: find_or_create_text_page(conn.request_path)
  end

  def sponsors(conn, _params) do
    render conn, "sponsors.html", page_content: find_or_create_text_page(conn.request_path)
  end

  defp find_next_team_matches(_query, []), do: []
  defp find_next_team_matches(query, [team | teams]) do
    [find_next_team_match(query, team) | find_next_team_matches(query, teams)]
  end

  defp find_next_team_match(query, team) do
    from(m in query, where: m.team_id == ^team.id)
    |> Repo.one
  end

  defp find_or_create_text_page(key) do
    case Repo.get_by(TextPage, key: key) do
      nil -> create_text_page(key)
      text_page -> text_page
    end
  end

  defp create_text_page(key) do
    changeset = TextPage.changeset(%TextPage{}, %{key: key, text: ""})
    {:ok, text_page} = Repo.insert(changeset)
    text_page
  end

  defp news_query(conn) do
    query = from(n in News, order_by: [desc: n.inserted_at], limit: 5)
    case logged_in?(conn) do
      true -> query
      false -> from(n in query, where: n.public == true)
    end
  end
end
