defmodule ClubHomepage.MatchTest do
  use ClubHomepage.ModelCase

  alias ClubHomepage.Match

  import ClubHomepage.Factory

  @valid_attrs %{season_id: 1, team_id: 1, opponent_team_id: 1, home_match: true, start_at: "17.04.2010 14:00"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    season = create(:season)
    team = create(:team)
    opponent_team = create(:opponent_team)
    {:ok, start_at} = Timex.DateFormat.parse(@valid_attrs[:start_at], "%d.%m.%Y %H:%M", :strftime)
    valid_attrs = %{@valid_attrs | season_id: season.id, team_id: team.id, opponent_team_id: opponent_team.id, start_at: start_at}
    changeset = Match.changeset(%Match{}, valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Match.changeset(%Match{}, @invalid_attrs)
    refute changeset.valid?
    assert changeset.errors[:season_id] == "can't be blank"
    assert changeset.errors[:team_id] == "can't be blank"
    assert changeset.errors[:opponent_team_id] == "can't be blank"
    assert changeset.errors[:start_at] == "can't be blank"
  end
end
