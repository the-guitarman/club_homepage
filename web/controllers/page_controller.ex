defmodule ClubHomepage.PageController do
  use ClubHomepage.Web, :controller

  alias ClubHomepage.Repo
  alias ClubHomepage.Match
  alias ClubHomepage.News
  alias ClubHomepage.Team

  def index(conn, _params) do
    news  = Repo.all(from(n in News, order_by: [desc: n.inserted_at], where: n.public == true, limit: 5))
    teams = Repo.all(Team)
    start_at = to_timex_ecto_datetime(Timex.Date.local)

    matches_query = from(m in Match, preload: [:competition, :team, :opponent_team], limit: 1)
    next_matches_query = from(m in matches_query, where: m.start_at > ^start_at, order_by: [asc: m.start_at])
    next_matches =
      find_next_team_matches(next_matches_query, teams)
      |> Enum.reject(fn(x) -> x == nil end)
    last_matches_query = from(m in matches_query, where: m.start_at < ^start_at, order_by: [desc: m.start_at])
    last_matches =
      find_next_team_matches(last_matches_query, teams)
    |> Enum.reject(fn(x) -> x == nil end)
    render conn, "index.html", teams: teams, news: news, next_matches: next_matches, last_matches: last_matches
  end

  def chronicle(conn, _params) do
    render conn, "chronicle.html"
  end

  def contact(conn, _params) do
    render conn, "contact.html"
  end

  def registration_information(conn, _params) do
    render conn, "registration_information.html"
  end

  def sponsors(conn, _params) do
    render conn, "sponsors.html"
  end

  def about_us(conn, _params) do
    render conn, "about_us.html"
  end

  defp find_next_team_matches(_query, []), do: []
  defp find_next_team_matches(query, [team | teams]) do
    [find_next_team_match(query, team) | find_next_team_matches(query, teams)]
  end

  defp find_next_team_match(query, team) do
    from(m in query, where: m.team_id == ^team.id)
    |> Repo.one
  end
end
