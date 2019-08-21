defmodule ClubHomepage.Extension.CommonSeason do
  import Ecto.Query, only: [from: 2]
  import ClubHomepageWeb.Router.Helpers
  import ClubHomepage.Extension.CommonTimex

  alias ClubHomepage.Match
  alias ClubHomepage.Repo
  alias ClubHomepage.Season

  def team_seasons(team) do
    season_ids = Repo.all(from(m in Match, join: s in assoc(m, :season), where: m.team_id == ^team.id, group_by: [m.season_id, s.name], select: m.season_id, order_by: [desc: s.name]))
    Repo.all(from(s in Season, where: s.id in ^season_ids))
    |> Enum.reverse
  end

  def current_team_season(team) do
    date =
      to_timex_ecto_datetime(Timex.now)
      |> Timex.add(Timex.Duration.from_days(30)) 
    query = from m in Match,
            where: m.team_id == ^team.id,
            where: m.start_at < ^date,
            select: m.season_id,
            order_by: [desc: m.start_at],
            limit: 1
    case Repo.one(query) do
      nil -> nil
      season_id -> Repo.get(Season, season_id)
    end
  end

  def team_with_season_path(conn, team) do
    case current_team_season(team) do
      nil    -> team_page_path(conn, :show, team.slug)
      season -> team_page_with_season_path(conn, :show, team.slug, season.name)
    end
  end




  def current_season_name do
    %{year: year, month: month} = Timex.now
    cond do
      month < 8 -> "#{year - 1}-#{year}"
      true      -> "#{year}-#{year + 1}"
    end
  end

  def current_season do
    Repo.get_by!(Season, name: current_season_name())
  end

  def current_season_id do
    current_season().id
  end
end
