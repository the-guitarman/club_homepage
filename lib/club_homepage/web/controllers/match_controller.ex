defmodule ClubHomepage.Web.MatchController do
  use ClubHomepage.Web, :controller

  alias ClubHomepage.Match
  alias ClubHomepage.MeetingPoint
  alias ClubHomepage.OpponentTeam
  alias ClubHomepage.Repo
  alias ClubHomepage.Season
  alias ClubHomepage.Team
  alias ClubHomepage.Web.JsonMatchesCreator
  alias ClubHomepage.Web.JsonMatchesValidator

  import ClubHomepage.Web.Localization

  plug :is_match_editor when not action in [:show]
  plug :scrub_params, "match" when action in [:create, :update]
  plug :get_competition_select_options when action in [:new, :new_bulk, :create, :create_bulk, :edit, :update]
  plug :get_season_select_options when action in [:new, :new_bulk, :create, :create_bulk, :edit, :update]
  plug :get_team_select_options when action in [:new, :new_bulk, :create, :create_bulk, :edit, :update]
  plug :get_opponent_team_select_options when action in [:new, :create, :edit, :update]
  plug :get_meeting_point_select_options when action in [:new, :create, :edit, :update]

  def index(conn, params) do
    matches = Repo.all(from(m in Match, preload: [:season, :team, :opponent_team, :meeting_point]))
    render(conn, "index.html", matches: matches, next_match_parameters: next_match_parameters(params))
  end

  def new(conn, params) do
    next_match_parameters = set_next_match_parameters(params)
    changeset = Match.changeset(%Match{}, next_match_parameters)
    render(conn, "new.html", changeset: changeset,
           competition_options: conn.assigns.competition_options,
           season_options: conn.assigns.season_options,
           team_options: conn.assigns.team_options,
           opponent_team_options: conn.assigns.opponent_team_options,
           meeting_point_options: conn.assigns.meeting_point_options)
  end

  def create(conn, %{"match" => match_params}) do
    match_params = parse_datetime_field(match_params, :start_at)
    match_params = parse_datetime_field(match_params, :meeting_point_at)
    changeset = Match.changeset(%Match{}, match_params)

    case Repo.insert(changeset) do
      {:ok, match} ->
        team = Repo.get(Team, match.team_id)
        season = Repo.get(Season, match.season_id)
        conn
        |> put_flash(:info, gettext("match_created_successfully"))
        #|> redirect(to: match_path(conn, :index, prepare_next_match_parameters(match_params)))
        |> redirect(to: team_page_with_season_path(conn, :show, team.slug, season.name, prepare_next_match_parameters(match)))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def new_bulk(conn, params) do
    match_params = 
      case params do
        %{"season_id" => season_id, "team_id" => team_id} -> %{"season_id" => season_id, "team_id" => team_id}
        _ -> %{}
      end
    changeset = JsonMatchesValidator.changeset(match_params)
    render(conn, "new_bulk.html", changeset: changeset,
           season_options: conn.assigns.season_options,
           team_options: conn.assigns.team_options)
  end

  def create_bulk(conn, %{"match" => match_params}) do
    json_field_name = :json
    changeset = JsonMatchesValidator.changeset([:season_id, :team_id, json_field_name], json_field_name, match_params)
    if changeset.valid? do
      JsonMatchesCreator.run(changeset, "json")
      changeset = JsonMatchesValidator.changeset(Map.delete(match_params, "json"))
      conn
      |> put_flash(:info, gettext("matches_created_successfully"))
      #|> redirect(to: match_path(conn, :index))
      |> render("new_bulk.html", changeset: changeset,
             season_options: conn.assigns.season_options,
             team_options: conn.assigns.team_options)
    else
      render(conn, "new_bulk.html", changeset: changeset,
             season_options: conn.assigns.season_options,
             team_options: conn.assigns.team_options)
    end
  end

  def show(conn, %{"id" => id}) do
    meeting_point_address_preload_query = from(mp in MeetingPoint, preload: [:address])
    opponent_team_address_preload_query = from(ot in OpponentTeam, preload: [:address])
    match = Repo.one!(from(m in Match, preload: [:season, :team, opponent_team: ^opponent_team_address_preload_query, meeting_point: ^meeting_point_address_preload_query], where: m.id == ^id))
#    match = Repo.get!(Match, id)
    render(conn, "show.html", match: match)
  end

  def edit(conn, %{"id" => id}) do
    match = Repo.get!(Match, id)
    changeset = Match.changeset(match)
    render(conn, "edit.html", match: match, changeset: changeset)
  end

  def update(conn, %{"id" => id, "match" => match_params}) do
    match_params = parse_datetime_field(match_params, :start_at)
    match_params = parse_datetime_field(match_params, :meeting_point_at)
    match = Repo.get!(Match, id)
    changeset = Match.changeset(match, match_params)

    case Repo.update(changeset) do
      {:ok, match} ->
        conn
        |> put_flash(:info, gettext("match_updated_successfully"))
        |> redirect(to: match_path(conn, :show, match))
      {:error, changeset} ->
        render(conn, "edit.html", match: match, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    match = Repo.get!(Match, id)
    team = Repo.get!(Team, match.team_id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(match)

    conn
    |> put_flash(:info, gettext("match_deleted_successfully"))
    #|> redirect(to: match_path(conn, :index))
    |> redirect(to: team_with_season_path(conn, team))
  end

  defp get_competition_select_options(conn, _) do
    query = from(s in ClubHomepage.Competition,
                 select: {s.name, s.id},
                 order_by: [desc: s.name])
    assign(conn, :competition_options, Repo.all(query))
  end

  defp get_season_select_options(conn, _) do
    query = from(s in ClubHomepage.Season,
      select: {s.name, s.id},
      order_by: [desc: s.name])
    assign(conn, :season_options, Repo.all(query))
  end

  defp get_team_select_options(conn, _) do
    query = from t in ClubHomepage.Team,
      select: {t.name, t.id},
      order_by: [asc: t.name]
    assign(conn, :team_options, Repo.all(query))
  end

  defp get_opponent_team_select_options(conn, _) do
    query = from ot in ClubHomepage.OpponentTeam,
      select: {ot.name, ot.id},
      order_by: [asc: ot.name]
    assign(conn, :opponent_team_options, Repo.all(query))
  end

  defp get_meeting_point_select_options(conn, _) do
    query = from mp in ClubHomepage.MeetingPoint,
      join: a in assoc(mp, :address),
      select: {[mp.name, " (", a.street, ", ", a.zip_code, " ", a.city, ")"], mp.id},
      order_by: [asc: mp.name]
    assign(conn, :meeting_point_options, Repo.all(query))
  end

  defp prepare_next_match_parameters(%ClubHomepage.Match{} = match) do
    %{"season_id" => match.season_id, "team_id" => match.team_id, "start_at" => next_start_at(match.start_at), "competition_id" => match.competition_id}
  end
  defp prepare_next_match_parameters(%{"season_id" => season_id, "team_id" => team_id, "start_at" => start_at} = params) do
    %{"season_id" => season_id, "team_id" => team_id, "start_at" => next_start_at(start_at), competition_id: params["competition_id"]}
  end

  defp next_start_at(start_at) do
    {:ok, start_at} =
      start_at
      |> Timex.add(Timex.Duration.from_days(7))
      |> Timex.format(datetime_format(), :strftime)
    start_at
  end

  defp next_match_parameters(%{"season_id" => season_id, "team_id" => team_id, "start_at" => start_at}) do
    %{"season_id" => season_id, "team_id" => team_id, "start_at" => start_at}
  end
  defp next_match_parameters(_), do: nil

  defp set_next_match_parameters(%{"season_id" => season_id, "team_id" => team_id, "start_at" => _start_at} = params) do
    %{"start_at" => start_at} = parse_datetime_field(params, :start_at)
    %{"season_id" => season_id, "team_id" => team_id, "start_at" => start_at}
  end
  defp set_next_match_parameters(%{"season_id" => season_id, "team_id" => team_id}) do
    %{"season_id" => season_id, "team_id" => team_id}
  end
  defp set_next_match_parameters(_), do: %{}
end
