defmodule ClubHomepage.TeamController do
  use ClubHomepage.Web, :controller

  alias ClubHomepage.Match
  alias ClubHomepage.PermalinkGenerator
  alias ClubHomepage.Team
  alias ClubHomepage.Season

  plug :scrub_params, "team" when action in [:create, :update]

  def index(conn, _params) do
    teams = Repo.all(Team)
    render(conn, "index.html", teams: teams)
  end

  def new(conn, _params) do
    changeset = Team.changeset(%Team{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"team" => team_params}) do
    changeset = Team.changeset(%Team{}, team_params)

    case Repo.insert(changeset) do
      {:ok, _team} ->
        PermalinkGenerator.run(changeset, :teams)
        conn
        |> put_flash(:info, "Team created successfully.")
        |> redirect(to: team_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    team = Repo.get!(Team, id)
    render(conn, "show.html", team: team)
  end

  def team_page(conn, %{"slug" => slug, "season" => season_name}) do
    team = Repo.get_by!(Team, slug: slug)
    season = Repo.get_by!(Season, name: season_name)
    matches = Repo.all(from(m in Match, preload: [:team, :opponent_team], where: [team_id: ^team.id, season_id: ^season.id]))
    render(conn, "team_page.html", team: team, season: season, seasons: team_seasons(team), matches: matches)
  end
  def team_page(conn, %{"slug" => slug}) do
    team = Repo.get_by!(Team, slug: slug)
    season =
      case team_seasons(team) do
        [] -> current_season
        [last_team_season | _] -> last_team_season
      end
    #render(conn, "team_page.html", team: team, season: season, seasons: seasons)
    redirect(conn, to: team_page_with_season_path(conn, :team_page, slug, season.name))
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
        |> put_flash(:info, "Team updated successfully.")
        |> redirect(to: team_path(conn, :show, team))
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
    |> put_flash(:info, "Team deleted successfully.")
    |> redirect(to: team_path(conn, :index))
  end
end
