defmodule ClubHomepage.Web.TeamController do
  require Logger

  use ClubHomepage.Web, :controller

  alias ClubHomepage.Match
  alias ClubHomepage.Web.PermalinkGenerator
  alias ClubHomepage.Team
  alias ClubHomepage.TeamImage
  alias ClubHomepage.Season
  alias ClubHomepage.StandardTeamPlayer
  alias ClubHomepage.User

  alias ClubHomepage.Web.Localization

  plug :is_team_editor when action in [:index, :new, :create, :edit, :update, :delete, :edit_standard_players]
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

  def show(conn, %{"slug" => slug, "season" => season_name} = params) do
    team = Repo.get_by!(Team, slug: slug)
    season = Repo.get_by!(Season, name: season_name)

    start_at = to_timex_ecto_datetime(Timex.local)

    query = from m in Match, preload: [:competition, :team, :opponent_team], where: [team_id: ^team.id, season_id: ^season.id]

    matches = Repo.all(from m in query, where: m.start_at > ^start_at, order_by: [asc: m.start_at])

    latest_matches = Repo.all(from m in query, where: m.start_at <= ^start_at, order_by: [desc: m.start_at])

    {current_table, current_table_created_at} =
      current_table(conn, team, team.fussball_de_team_rewrite, team.fussball_de_team_id)

    render(conn, "team_page.html", team: team, season: season, seasons: team_seasons(team), matches: matches, latest_matches: latest_matches, next_match_parameters: %{"season_id" => season.id, "team_id" => team.id, "start_at" => params["start_at"], "competition_id" => params["competition_id"]}, team_images_count: team_images_count(team), current_table: current_table, current_table_created_at: current_table_created_at)
  end
  def show(conn, %{"slug" => slug}) do
    team = Repo.get_by!(Team, slug: slug)
    season =
      case team_seasons(team) do
        [] -> current_season()
        [last_team_season | _] -> last_team_season
      end
    redirect(conn, to: team_page_with_season_path(conn, :show, slug, season.name))
  end

  def show_images(conn, %{"slug" => slug}) do
    team = Repo.get_by!(Team, slug: slug)
    team_images = Repo.all(from ti in TeamImage, where: [team_id: ^team.id]) || []
    # matches_count = 
    #   case current_team_season(team) do
    #     nil -> 0
    #     season -> 
    #       start_at = to_timex_ecto_datetime(Timex.local)
    #       query = from(m in Match, where: [team_id: ^team.id, season_id: ^season.id])
    #       [count] = Repo.all(from m in query, select: count("id"), where: m.start_at > ^start_at)
    #       count
    #   end
    render(conn, "team_images_page.html", team: team, team_images: team_images) #, matches_count: matches_count)
  end

  def show_chat(conn, %{"id" => id}) do
    team = Repo.get!(Team, id)
    render(conn, "team_chat_page.html", team: team, team_images_count: team_images_count(team))
  end

  def edit_standard_players(conn, %{"slug" => slug}) do
    team = Repo.get_by!(Team, slug: slug)
    team_images = Repo.all(from ti in TeamImage, where: [team_id: ^team.id]) || []
    all_players = Repo.all(
      from u in User,
      left_join: stp in StandardTeamPlayer,
      on: u.id == stp.user_id,
      where: stp.team_id == ^team.id ,where: [roles: "player"], or_where: like(u.roles, "player %"), or_where: like(u.roles, "% player %"), or_where: like(u.roles, "% player"),
      order_by: [stp.id, u.name],
      select: %{id: u.id, name: u.name, nickname: u.nickname, standard_team_player_id: stp.id, standard_shirt_number: stp.standard_shirt_number}
    )
    render(conn, "team_standard_players_page.html", team: team, team_images: team_images, all_players: all_players)
  end

  def download_ical(conn, %{"slug" => slug, "season" => season_name} = _params) do
    team = Repo.get_by!(Team, slug: slug)
    season = Repo.get_by!(Season, name: season_name)

    conn
    |> put_resp_content_type("text/calendar")
    |> put_resp_header("content-disposition", "attachment; filename=\"#{team.name}.ics\"")
    |> send_resp(200, ClubHomepage.Web.MatchCalendarCreator.run(team.id, season.id))
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

  defp team_images_count(team) do
    [team_images_count] = Repo.all(from ti in TeamImage, select: count("id"), where: [team_id: ^team.id]) || 0
    team_images_count
  end

  defp current_table(conn, team, club_rewrite, team_id) when is_binary(club_rewrite) and is_binary(team_id) do
      team
      |> current_table_language_check()
      |> current_table_browser_check(conn)
      |> current_table_scraper(club_rewrite, team_id)
      |> current_table_log_error(Mix.env(), club_rewrite, team_id)
      |> current_table_response(team)
  end
  defp current_table(_, _, _, _), do: {nil, nil}

  defp current_table_language_check(%Team{} = team) do
    case team.fussball_de_show_current_table do
      true -> {:ok, current_table_current_locale(), created_at()}
      _ -> {:error, :show_current_table_is_off, created_at()}
    end
  end

  defp current_table_browser_check(language_check, conn) do
    case language_check do
      {:ok, "de", _} ->
        case Browser.bot?(conn) do #|| Browser.search_engine?(conn) do
          true -> {:error, :request_from_bot_or_search_engine, created_at()}
          _ -> language_check
        end
      {:ok, language, created_at} -> {:error, "'#{language}' is the wrong language.", created_at}
      {:error, _, _} -> language_check
    end
  end

  defp current_table_current_locale do
    case Mix.env() do
      :test -> "de"
      _ -> Localization.current_locale()
    end
  end

  defp current_table_scraper(browser_check, club_rewrite, team_id) do
    case browser_check do
      {:ok, "de", _} -> ExFussballDeScraper.Scraper.current_table(club_rewrite, team_id)
      {:error, _, _} -> browser_check
    end
  end

  defp current_table_response(scraper_result, %Team{} = team) do
    case scraper_result do
      {:ok, %{team_name: team_name, current_table: html}, created_at} ->
        {
          replace_scraper_team_name(html, team_name, team),
          scraper_result_time(created_at)
        }
      {:error, _, _} ->
        {nil, nil}
    end
  end

  defp replace_scraper_team_name(html, scraper_team_name, team) do
    String.replace(html, scraper_team_name, team.name)
  end

  defp scraper_result_time(timestamp) do
    timestamp
    |> Timex.from_unix()
    |> Timex.Timezone.convert(Timex.Timezone.Local.lookup())
  end

  defp created_at() do
    Timex.local()
    |> Timex.to_unix()
  end

  defp current_table_log_error(scraper_result, :test, _, _) do
    scraper_result
  end
  defp current_table_log_error(scraper_result, _env, club_rewrite, team_id) do
    case scraper_result do
      {:error, reason, created_at} ->
        Logger.error("ExFussballDeScraper.Scraper.current_table(\"#{club_rewrite}\", \"#{team_id}\"): #{reason}, at: #{scraper_result_time(created_at)}")
        scraper_result
      _ -> scraper_result
    end
  end
end
