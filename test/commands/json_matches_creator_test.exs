defmodule ClubHomepage.JsonMatchesCreatorTest do
  use ClubHomepage.ModelCase
  use ExUnit.Case
  doctest ClubHomepage.Web.JsonMatchesCreator

  alias ClubHomepage.Web.JsonMatchesValidator
  alias ClubHomepage.Web.JsonMatchesCreator
  alias ClubHomepage.Competition
  alias ClubHomepage.Match
  alias ClubHomepage.OpponentTeam

  import ClubHomepage.Factory
  import Ecto.Query, only: [from: 2]

  @params %{"json" => "{\r\n  \"team_name\": \"Club Team\",\r\n  \"matches\": [\r\n    {\r\n      \"competition\": \"League A\",\r\n      \"start_at\": \"2016-03-13T12:00:00+01:00\",\r\n      \"home\": \"Opponent Team 1\",\r\n      \"guest\": \"Club Team\"\r\n    },\r\n    {\r\n      \"competition\": \"Super Cup\",\r\n      \"start_at\": \"2016-04-03T14:00:00+02:00\",\r\n      \"home\": \"Club Team\",\r\n      \"guest\": \"Opponent Team 2\"\r\n    }\r\n  ]\r\n}"}

  test "create matches from json" do
    season = insert(:season)
    team   = insert(:team)
    params = 
      @params
      |> Map.put("season_id", season.id)
      |> Map.put("team_id", team.id)
    changeset = JsonMatchesValidator.changeset(["season_id", "team_id", "json"], "json", params)
    assert changeset.valid?
    assert changeset.errors == []

    assert count(Competition) == 2
    assert count(Match) == 0
    assert count(OpponentTeam) == 0

    records_count = JsonMatchesCreator.run(changeset, "json")
    assert records_count == 2
    assert count(Competition) == 4
    assert count(Match) == 2
    assert count(OpponentTeam) == 2

    match1 = Repo.one!(from(m in Match, where: [team_id: ^team.id, home_match: false], preload: [:team, :opponent_team]))
    assert match1.team.name == team.name
    assert match1.opponent_team.name == "Opponent Team 1"
    assert match1.home_match == false
    assert match1.start_at == Timex.to_datetime({{2016, 3, 13}, {11, 0, 0}})

    match2 = Repo.one!(from(m in Match, where: [team_id: ^team.id, home_match: true], preload: [:team, :opponent_team]))
    assert match2.team.name == team.name
    assert match2.opponent_team.name == "Opponent Team 2"
    assert match2.home_match == true
    assert match2.start_at == Timex.to_datetime({{2016, 4, 3}, {12, 0, 0}})
  end

  defp count(model) do
    from(m in model, select: count(m.id))
    |> Repo.one
  end
end
