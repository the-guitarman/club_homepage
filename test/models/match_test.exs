defmodule ClubHomepage.MatchTest do
  use ClubHomepage.ModelCase

  alias ClubHomepage.Match

  @valid_attrs %{season_id: 1, team_id: 1, opponent_team_id: 1, home_match: true, start_at: "2010-04-17 14:00:00"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Match.changeset(%Match{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Match.changeset(%Match{}, @invalid_attrs)
    refute changeset.valid?
  end
end
