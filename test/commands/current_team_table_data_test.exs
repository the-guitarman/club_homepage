defmodule ClubHomepage.Web.CurrentTeamTableDataTest do
  use ClubHomepage.Web.ConnCase

  #alias ClubHomepage.Match
  alias ClubHomepage.Team
  alias ClubHomepage.Repo
  alias ClubHomepage.Web.CurrentTeamTableData

  import ClubHomepage.Factory

  setup do
    conn =
      build_conn()
      |> bypass_through(ClubHomepage.Web.Router, :browser)
      |> get("/")
    {:ok, %{conn: conn}}
  end

  test "no club_rewrite or no team_id given", %{conn: conn} do
    team = insert(:team, fussball_de_team_rewrite: nil, fussball_de_team_id: nil)

    {:error, error, _} = CurrentTeamTableData.run(conn, team)

    assert error == :no_club_rewrite_or_team_id_available

    team = Repo.get(Team, team.id)
    assert team.current_table_html == nil
    assert team.current_table_html_at == nil
  end

  test "no download for current table because config is off", %{conn: conn} do
    team = insert(:team, fussball_de_team_rewrite: "abc", fussball_de_team_id: "ghi123", fussball_de_show_current_table: false, current_table_html: nil, current_table_html_at: nil)

    {:error, error, _} = CurrentTeamTableData.run(conn, team)

    assert error == :show_current_table_is_off

    team = Repo.get(Team, team.id)
    assert team.current_table_html == nil
    assert team.current_table_html_at == nil
  end

  test "no check for next team matches because of request from a bot", %{conn: conn} do
    team = insert(:team, fussball_de_team_rewrite: "abc", fussball_de_team_id: "ghi123", fussball_de_show_current_table: true, current_table_html: nil, current_table_html_at: nil)

    conn = conn |> put_req_header("user-agent", "DuckDuckBot")
    {:error, error, _} = CurrentTeamTableData.run(conn, team)

    assert error == :request_from_bot_or_search_engine

    team = Repo.get(Team, team.id)
    assert team.current_table_html == nil
    assert team.current_table_html_at == nil
  end

  test "no check for next team matches because of request from a search engine", %{conn: conn} do
    team = insert(:team, fussball_de_team_rewrite: "abc", fussball_de_team_id: "ghi123", fussball_de_show_current_table: true, current_table_html: nil, current_table_html_at: nil)

    conn = conn |> put_req_header("user-agent", "duckduck")
    {:error, error, _} = CurrentTeamTableData.run(conn, team)

    assert error == :request_from_bot_or_search_engine

    team = Repo.get(Team, team.id)
    assert team.current_table_html == nil
    assert team.current_table_html_at == nil
  end

  test "caching of the current team table", %{conn: conn} do
    team = insert(:team, fussball_de_team_rewrite: "abc", fussball_de_team_id: "ghi123", fussball_de_show_current_table: true, current_table_html: nil, current_table_html_at: nil)

    {:ok, html, timex} = CurrentTeamTableData.run(conn, team)

    assert is_binary(html)

    team = Repo.get(Team, team.id)
    assert team.current_table_html == html
    assert team.current_table_html_at == Timex.to_datetime(timex)
  end

  test "returns cached team table", %{conn: conn} do
    now = Timex.now()

    team = insert(:team, fussball_de_team_rewrite: "abc", fussball_de_team_id: "123", fussball_de_show_current_table: true, current_table_html: "test html", current_table_html_at: Timex.to_datetime(now))

    {:ok, html, timex} = CurrentTeamTableData.run(conn, team)
    assert html == "test html"
    assert not(is_nil(timex))

    _match = insert(:match, team_id: team.id, start_at: start_at(days: -2))
    {:ok, html, timex} = CurrentTeamTableData.run(conn, team)
    assert html == "test html"
    assert not(is_nil(timex))

    _match = insert(:match, team_id: team.id, start_at: start_at(days: -1))
    {:ok, html, timex} = CurrentTeamTableData.run(conn, team)
    assert html == "test html"
    assert not(is_nil(timex))

    _match = insert(:match, team_id: team.id, start_at: start_at(hours: -3))
    {:ok, html, timex} = CurrentTeamTableData.run(conn, team)
    assert html == "test html"
    assert not(is_nil(timex))

    _match = insert(:match, team_id: team.id, start_at: start_at(hours: -2))
    {:ok, html, timex} = CurrentTeamTableData.run(conn, team)
    assert html == "test html"
    assert not(is_nil(timex))

    _match = insert(:match, team_id: team.id, start_at: start_at(hours: -1))
    {:ok, html, timex} = CurrentTeamTableData.run(conn, team)
    assert is_binary(html)
    assert html != "test html"
    assert not(is_nil(timex))
  end

  defp start_at(shift_keywords_from_now) do
    Timex.now()
    |> Timex.shift(shift_keywords_from_now)
  end
end
