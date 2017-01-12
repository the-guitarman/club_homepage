defmodule ClubHomepage.MatchCalendarCreatorTest do
  use ClubHomepage.ModelCase
  use ExUnit.Case
  doctest ClubHomepage.MatchCalendarCreator

  alias ClubHomepage.Competition
  alias ClubHomepage.Match
  alias ClubHomepage.MatchCalendarCreator
  alias ClubHomepage.OpponentTeam
  alias ClubHomepage.Repo
  alias ClubHomepage.Team

  import ClubHomepage.Factory

  setup do
    season = insert(:season)
    team   = insert(:team)
    {:ok, season_id: season.id, team_id: team.id}
  end

  test "run", %{season_id: season_id, team_id: team_id} do
    Repo.delete_all(Match)
    assert MatchCalendarCreator.run(team_id, season_id) == "BEGIN:VCALENDAR\nCALSCALE:GREGORIAN\nVERSION:2.0\nEND:VCALENDAR\n"

    match = insert(:match, season_id: season_id, team_id: team_id, start_at:  Timex.add(Timex.local, Timex.Duration.from_days(1)))
    result = MatchCalendarCreator.run(team_id, season_id)
    assert String.contains?(result, "UID:" <> uid(match))
    assert String.contains?(result, "SUMMARY:" <> summary(match))
  end

  test "available?", %{season_id: season_id, team_id: team_id} do
    Repo.delete_all(Match)

    assert MatchCalendarCreator.available?(team_id, season_id) == false

    _match = insert(:match, season_id: season_id, team_id: team_id, start_at:  Timex.to_datetime({{2016, 4, 2}, {12, 30, 0}}, :local))
    assert MatchCalendarCreator.available?(team_id, season_id) == false

    _match = insert(:match, season_id: season_id, team_id: team_id, start_at:  Timex.add(Timex.local, Timex.Duration.from_days(1)))
    assert MatchCalendarCreator.available?(team_id, season_id)
  end

  defp uid(match) do
    competition = Repo.get(Competition, match.competition_id)
    :crypto.hash(:sha, "#{match.id}#{summary(match)}#{competition.name}")
    |> Base.encode16(case: :lower)
  end

  defp summary(match) do
    team = Repo.get(Team, match.team_id)
    opponent_team = Repo.get(OpponentTeam, match.opponent_team_id)
    if match.home_match do
      team.name <> " - " <> opponent_team.name
    else
      opponent_team.name <> " - " <> team.name
    end
  end
end
