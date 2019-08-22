defmodule ClubHomepage.JsonMatchesCreatorTest do
  use ClubHomepage.ModelCase
  use ExUnit.Case
  doctest ClubHomepageWeb.JsonMatchesCreator

  alias ClubHomepageWeb.JsonMatchesValidator
  alias ClubHomepageWeb.JsonMatchesCreator
  alias ClubHomepage.Competition
  alias ClubHomepage.Match
  alias ClubHomepage.OpponentTeam
  alias ClubHomepage.Repo

  import ClubHomepage.Factory
  import Ecto.Query, only: [from: 2]

  @competition_1 "League A"
  @competition_2 "Super Cup"
  @params %{"json" => "{\r\n  \"season\": \"2015-2016\",\r\n  \"team_name\": \"Club Team\",\r\n  \"matches\": [\r\n    {\r\n      \"competition\": \"#{@competition_1}\",\r\n      \"start_at\": \"2016-03-13T12:00:00+01:00\",\r\n      \"home\": \"Opponent Team 1\",\r\n      \"guest\": \"Club Team\"\r\n    },\r\n    {\r\n      \"competition\": \"#{@competition_2}\",\r\n      \"start_at\": \"2016-04-03T14:00:00+02:00\",\r\n      \"home\": \"Club Team\",\r\n      \"guest\": \"Opponent Team 2\"\r\n    },\r\n    {\r\n      \"competition\": \"#{@competition_1}\",\r\n      \"start_at\": \"2016-04-10T15:00:00+02:00\",\r\n      \"home\": \"Club Team\",\r\n      \"guest\": \"Opponent Team 2\"\r\n    }\r\n  ]\r\n}"}

  test "create matches from json" do
    team   = insert(:team)
    params = 
      @params
      |> Map.put("team_id", team.id)

    changeset = JsonMatchesValidator.changeset(~w(team_id json)a, "json", params)

    assert changeset.valid?
    assert changeset.errors == []

    competition_count = Repo.count(Competition)
    match_count = Repo.count(Match)
    opponent_team_count = Repo.count(OpponentTeam)

    records_count = JsonMatchesCreator.run(changeset, "json")
    assert records_count == 3

    assert Repo.count(Competition) == competition_count + 2
    assert Repo.count(Match) ==  match_count + 3
    assert Repo.count(OpponentTeam) == opponent_team_count + 2

    competition_1 = Repo.get_by(Competition, name: @competition_1)
    competition_2 = Repo.get_by(Competition, name: @competition_2)

    match1 = Repo.one!(from(m in Match, where: [team_id: ^team.id, home_match: false, competition_id: ^competition_1.id], preload: [:team, :season, :competition, :opponent_team]))
    assert match1.team.name == team.name
    assert match1.opponent_team.name == "Opponent Team 1"
    assert match1.home_match == false
    assert match1.start_at == Timex.to_datetime({{2016, 3, 13}, {11, 0, 0}})
    assert match1.season.name == "2015-2016"
    assert match1.competition.name == @competition_1

    match2 = Repo.one!(from(m in Match, where: [team_id: ^team.id, home_match: true, competition_id: ^competition_2.id], preload: [:team, :season, :competition, :opponent_team]))
    assert match2.team.name == team.name
    assert match2.opponent_team.name == "Opponent Team 2"
    assert match2.home_match == true
    assert match2.start_at == Timex.to_datetime({{2016, 4, 3}, {12, 0, 0}})
    assert match2.season.name == "2015-2016"
    assert match2.competition.name == @competition_2

    match3 = Repo.one!(from(m in Match, where: [team_id: ^team.id, home_match: true, competition_id: ^competition_1.id], preload: [:team, :season, :competition, :opponent_team]))
    assert match3.team.name == team.name
    assert match3.opponent_team.name == "Opponent Team 2"
    assert match3.home_match == true
    assert match3.start_at == Timex.to_datetime({{2016, 4, 10}, {13, 0, 0}})
    assert match3.season.name == "2015-2016"
    assert match3.competition.name == @competition_1
  end
end
