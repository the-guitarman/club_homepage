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

  test "caching of the current team table", %{conn: conn} do
    team = insert(:team, fussball_de_team_rewrite: "abc", fussball_de_team_id: "ghi123", fussball_de_show_current_table: true, current_table_html: nil, current_table_html_at: nil)

    {html, timex} = CurrentTeamTableData.run(conn, team)

    assert is_binary(html)

    team = Repo.get(Team, team.id)
    assert team.current_table_html == html
    assert team.current_table_html_at == Timex.to_datetime(timex)
  end

  test "returns cached team table", %{conn: conn} do
    now = Timex.now()

    team = insert(:team, fussball_de_team_rewrite: "abc", fussball_de_team_id: "123", fussball_de_show_current_table: true, current_table_html: "test html", current_table_html_at: Timex.to_datetime(now))

    {html, timex} = CurrentTeamTableData.run(conn, team)
    assert html == "test html"
    assert not(is_nil(timex))

    _match = insert(:match, team_id: team.id, start_at: start_at(days: -2))
    {html, timex} = CurrentTeamTableData.run(conn, team)
    assert html == "test html"
    assert not(is_nil(timex))

    _match = insert(:match, team_id: team.id, start_at: start_at(days: -1))
    {html, timex} = CurrentTeamTableData.run(conn, team)
    assert html == "test html"
    assert not(is_nil(timex))

    _match = insert(:match, team_id: team.id, start_at: start_at(hours: -3))
    {html, timex} = CurrentTeamTableData.run(conn, team)
    assert html == "test html"
    assert not(is_nil(timex))

    _match = insert(:match, team_id: team.id, start_at: start_at(hours: -2))
    {html, timex} = CurrentTeamTableData.run(conn, team)
    assert html == "test html"
    assert not(is_nil(timex))

    _match = insert(:match, team_id: team.id, start_at: start_at(hours: -1))
    {html, timex} = CurrentTeamTableData.run(conn, team)
    assert is_binary(html)
    assert html != "test html"
    assert not(is_nil(timex))
  end

  defp start_at(shift_keywords_from_now) do
    Timex.now()
    |> Timex.shift(shift_keywords_from_now)
  end
end
