defmodule ClubHomepage.Web.NewTeamMatchesDataTest do
  use ClubHomepage.Web.ConnCase

  #alias ClubHomepage.Match
  alias ClubHomepage.Team
  alias ClubHomepage.Repo
  alias ClubHomepage.Web.NewTeamMatchesData

  import ClubHomepage.Factory

  setup do
    conn =
      build_conn()
      |> bypass_through(ClubHomepage.Web.Router, :browser)
      |> get("/")
    {:ok, %{conn: conn}}
  end

  test "no check for next team matches because config is off", %{conn: conn} do
    team = insert(:team, fussball_de_team_rewrite: "abc", fussball_de_team_id: "ghi123", fussball_de_show_next_matches: false, fussball_de_last_next_matches_check_at: nil)

    {:error, error, _} = NewTeamMatchesData.run(conn, team)

    assert error == :show_next_matches_is_off

    team = Repo.get(Team, team.id)
    assert is_nil(team.fussball_de_last_next_matches_check_at)
  end

  test "no check for next team matches because of request from a bot", %{conn: conn} do
    team = insert(:team, fussball_de_team_rewrite: "abc", fussball_de_team_id: "ghi123", fussball_de_show_next_matches: true, fussball_de_last_next_matches_check_at: nil)

    conn = conn |> put_req_header("user-agent", "DuckDuckBot")
    {:error, error, _} = NewTeamMatchesData.run(conn, team)

    assert error == :request_from_bot_or_search_engine

    team = Repo.get(Team, team.id)
    assert is_nil(team.fussball_de_last_next_matches_check_at)
  end

  test "no check for next team matches because of request from a search engine", %{conn: conn} do
    team = insert(:team, fussball_de_team_rewrite: "abc", fussball_de_team_id: "ghi123", fussball_de_show_next_matches: true, fussball_de_last_next_matches_check_at: nil)

    conn = conn |> put_req_header("user-agent", "duckduck")
    {:error, error, _} = NewTeamMatchesData.run(conn, team)

    assert error == :request_from_bot_or_search_engine

    team = Repo.get(Team, team.id)
    assert is_nil(team.fussball_de_last_next_matches_check_at)
  end

  test "no check for next team matches because it's done for today", %{conn: conn} do
    now = Timex.now()
    team = insert(:team, fussball_de_team_rewrite: "abc", fussball_de_team_id: "ghi123", fussball_de_show_next_matches: true, fussball_de_last_next_matches_check_at: now)

    {:error, error, _} = NewTeamMatchesData.run(conn, team)

    assert error == :next_matches_check_done_today

    team = Repo.get(Team, team.id)
    assert team.fussball_de_last_next_matches_check_at == now
  end

  test "check for next team matches", %{conn: conn} do
    team = insert(:team, fussball_de_team_rewrite: "abc", fussball_de_team_id: "ghi123", fussball_de_show_next_matches: true, fussball_de_last_next_matches_check_at: nil)

    {:ok, %{matches: matches, team_name: team_name}, _} = NewTeamMatchesData.run(conn, team)

    assert is_list(matches)
    assert Enum.empty?(matches)
    assert team_name == ""

    team = Repo.get(Team, team.id)
    assert not(is_nil(team.fussball_de_last_next_matches_check_at))
  end
end
