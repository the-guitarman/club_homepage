defmodule ClubHomepage.TeamController do
  use ClubHomepage.Web, :controller

  alias ClubHomepage.Match
  alias ClubHomepage.PermalinkGenerator
  alias ClubHomepage.Team
  alias ClubHomepage.Season

  plug :is_team_editor? when action in [:index, :new, :create, :edit, :update, :delete]
  plug :scrub_params, "team" when action in [:create, :update]
  plug :get_competition_select_options when action in [:new, :create, :edit, :update]

  def index(conn, _params) do
    teams = Repo.all(Team)
    render(conn, "index.html", teams: teams)
  end

  def new(conn, _params) do
    changeset = Team.changeset(%Team{})
    render(conn, "new.html", changeset: changeset,
           competition_options: conn.assigns.competition_options
    )
  end

  def create(conn, %{"team" => team_params}) do
    changeset = Team.changeset(%Team{}, team_params)

    case Repo.insert(changeset) do
      {:ok, team} ->
        PermalinkGenerator.run(changeset, :teams)
        conn
        |> put_flash(:info, gettext("team_created_successfully"))
        |> redirect(to: team_path(conn, :index) <> "#team-#{team.id}")
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"slug" => slug, "season" => season_name}) do
    team = Repo.get_by!(Team, slug: slug)
    season = Repo.get_by!(Season, name: season_name)

    query = from(m in Match, preload: [:competition, :team, :opponent_team], where: [team_id: ^team.id, season_id: ^season.id])
    start_at = to_timex_ecto_datetime(Timex.Date.local)
    matches = Repo.all(from m in query, where: m.start_at > ^start_at)
    latest_matches = Repo.all(from m in query, where: m.start_at <= ^start_at)
    render(conn, "team_page.html", team: team, season: season, seasons: team_seasons(team), matches: matches, latest_matches: latest_matches)
  end
  def show(conn, %{"slug" => slug}) do
    team = Repo.get_by!(Team, slug: slug)
    season =
      case team_seasons(team) do
        [] -> current_season
        [last_team_season | _] -> last_team_season
      end
    redirect(conn, to: team_page_with_season_path(conn, :show, slug, season.name))
  end

  def edit(conn, %{"id" => id}) do
    team = Repo.get!(Team, id)
    changeset = Team.changeset(team)
    render(conn, "edit.html", team: team, changeset: changeset)
  end

  def update(conn, %{"id" => id, "team" => team_params}) do
    team = Repo.get!(Team, id)
    changeset = Team.changeset(team, team_params)

    case Repo.update(changeset) do
      {:ok, team} ->
        PermalinkGenerator.run(changeset, :teams)
        conn
        |> put_flash(:info, gettext("team_updated_successfully"))
        |> redirect(to: team_path(conn, :index) <> "#team-#{team.id}")
      {:error, changeset} ->
        render(conn, "edit.html", team: team, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    team = Repo.get!(Team, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(team)

    conn
    |> put_flash(:info, gettext("team_deleted_successfully"))
    |> redirect(to: team_path(conn, :index))
  end

  defp get_competition_select_options(conn, _) do
    query = from(s in ClubHomepage.Competition,
                 select: {s.name, s.id},
                 order_by: [asc: s.name])
    assign(conn, :competition_options, Repo.all(query))
  end
end
