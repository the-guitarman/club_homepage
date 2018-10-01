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

  test "caching of the current team table", %{conn: conn} do
    team = insert(:team, fussball_de_team_rewrite: "abc", fussball_de_team_id: "ghi123", fussball_de_show_next_matches: true, fussball_de_last_next_matches_check_at: nil)

    {:ok, %{matches: matches, team_name: team_name}, _} = NewTeamMatchesData.run(conn, team)

    assert is_list(matches)
    assert Enum.empty?(matches)
    assert team_name == ""

    team = Repo.get(Team, team.id)
    assert not(is_nil(team.fussball_de_last_next_matches_check_at))
  end
end
