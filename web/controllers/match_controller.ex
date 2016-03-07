defmodule ClubHomepage.MatchController do
  use ClubHomepage.Web, :controller

  alias ClubHomepage.Match
  alias ClubHomepage.MatchesJsonValidator

  plug :scrub_params, "match" when action in [:create, :update]
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
           season_options: conn.assigns.season_options,
           team_options: conn.assigns.team_options,
           opponent_team_options: conn.assigns.opponent_team_options,
           meeting_point_options: conn.assigns.meeting_point_options)
  end

  def create(conn, %{"match" => match_params}) do
    match_params = parse_datetime_field(match_params, :start_at)
    changeset = Match.changeset(%Match{}, match_params)

    case Repo.insert(changeset) do
      {:ok, _match} ->
        conn
        |> put_flash(:info, "Match created successfully.")
        |> redirect(to: match_path(conn, :index, prepare_next_match_parameters(match_params)))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def new_bulk(conn, _params) do
    changeset = MatchesJsonValidator.changeset
    render(conn, "new_bulk.html", changeset: changeset,
           season_options: conn.assigns.season_options,
           team_options: conn.assigns.team_options)
  end

  def create_bulk(conn, %{"match" => match_params}) do
    json_field_name = :json
    changeset = MatchesJsonValidator.changeset([:season_id, :team_id, json_field_name], json_field_name, match_params)
    if changeset.valid? do
      {:ok, map} = JSON.decode(match_params[Atom.to_string(json_field_name)])
      #redirect(to: match_path(conn, :index))
      render(conn, "new_bulk.html", changeset: changeset,
             season_options: conn.assigns.season_options,
             team_options: conn.assigns.team_options)
    else
      render(conn, "new_bulk.html", changeset: changeset,
             season_options: conn.assigns.season_options,
             team_options: conn.assigns.team_options)
    end
  end

  def show(conn, %{"id" => id}) do
    match = Repo.one!(from(m in Match, preload: [:season, :team, :opponent_team, :meeting_point], where: m.id == ^id))
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
    match = Repo.get!(Match, id)
    changeset = Match.changeset(match, match_params)

    case Repo.update(changeset) do
      {:ok, match} ->
        conn
        |> put_flash(:info, "Match updated successfully.")
        |> redirect(to: match_path(conn, :show, match))
      {:error, changeset} ->
        render(conn, "edit.html", match: match, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    match = Repo.get!(Match, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(match)

    conn
    |> put_flash(:info, "Match deleted successfully.")
    |> redirect(to: match_path(conn, :index))
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
      select: {a.street, mp.id},
      order_by: [asc: mp.name]
    assign(conn, :meeting_point_options, Repo.all(query))
  end

  defp prepare_next_match_parameters(%{"season_id" => season_id, "team_id" => team_id, "start_at" => start_at}) do
    {:ok, start_at} =
      start_at
      |> Timex.Date.add(Timex.Time.to_timestamp(7, :days))
      |> Timex.DateFormat.format("%d.%m.%Y %H:%M", :strftime)
    %{"season_id" => season_id, "team_id" => team_id, "start_at" => start_at}
  end

  defp next_match_parameters(%{"season_id" => season_id, "team_id" => team_id, "start_at" => start_at}) do
    %{"season_id" => season_id, "team_id" => team_id, "start_at" => start_at}
  end
  defp next_match_parameters(_), do: nil

  defp set_next_match_parameters(%{"season_id" => season_id, "team_id" => team_id, "start_at" => _start_at} = params) do
    %{"start_at" => start_at} = parse_datetime_field(params, :start_at)
    %{"season_id" => season_id, "team_id" => team_id, "start_at" => start_at}
  end
  defp set_next_match_parameters(_), do: %{}
end
