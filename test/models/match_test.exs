defmodule ClubHomepage.MatchTest do
  use ClubHomepage.ModelCase

  alias ClubHomepage.Match

  import ClubHomepage.Factory

  @valid_attrs %{competition_id: 1, season_id: 1, team_id: 1, opponent_team_id: 1, home_match: true, start_at: "17.04.2010 14:00"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    competition   = create(:competition)
    season        = create(:season)
    team          = create(:team)
    opponent_team = create(:opponent_team)
    {:ok, start_at} = Timex.DateFormat.parse(@valid_attrs[:start_at], "%d.%m.%Y %H:%M", :strftime)
    valid_attrs = %{@valid_attrs | competition_id: competition.id, season_id: season.id, team_id: team.id, opponent_team_id: opponent_team.id, start_at: start_at}
    changeset = Match.changeset(%Match{}, valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Match.changeset(%Match{}, @invalid_attrs)
    refute changeset.valid?
    assert changeset.errors[:competition_id] == "can't be blank"
    assert changeset.errors[:season_id] == "can't be blank"
    assert changeset.errors[:team_id] == "can't be blank"
    assert changeset.errors[:opponent_team_id] == "can't be blank"
    assert changeset.errors[:start_at] == "can't be blank"
  end

  test "match is finished" do
    start_at = Timex.Date.local
    match = %Match{start_at: start_at}
    assert not Match.finished?(match)

    # match has been started two hours ago
    start_at = Timex.Date.add(start_at, Timex.Time.to_timestamp(-4, :hours))
    match = %Match{start_at: start_at}
    assert Match.finished?(match)
  end

  test "match is in progress" do
    # match starts in an 1 hour
    start_at = Timex.Date.add(Timex.Date.local, Timex.Time.to_timestamp(1, :hours))
    match = %Match{start_at: start_at}
    assert not Match.in_progress?(match)

    # match has been started one hour ago
    start_at = Timex.Date.add(Timex.Date.local, Timex.Time.to_timestamp(-1, :hours))
    match = %Match{start_at: start_at}
    assert Match.in_progress?(match)

    # match has been started two hours ago
    start_at = Timex.Date.add(Timex.Date.local, Timex.Time.to_timestamp(-4, :hours))
    match = %Match{start_at: start_at}
    assert not Match.in_progress?(match)
  end

  test "validate goals with failure_reason is 'aborted'" do
    attrs = Map.put(@valid_attrs, :failure_reason, "aborted")
    changeset = Match.changeset(%Match{}, attrs)
    assert changeset.errors[:team_goals] == "can't be blank"
    assert changeset.errors[:opponent_team_goals] == "can't be blank"
  end

  test "validate goals with failure_reason other than 'aborted'" do
    attrs = Map.put(@valid_attrs, :failure_reason, "canceled")
    changeset = Match.changeset(%Match{}, attrs)
    assert changeset.errors[:team_goals] == nil
    assert changeset.errors[:opponent_team_goals] == nil
  end
end
