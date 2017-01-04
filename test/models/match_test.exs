defmodule ClubHomepage.MatchTest do
  use ClubHomepage.ModelCase

  alias ClubHomepage.Match

  import ClubHomepage.Factory

  @valid_attrs %{competition_id: 1, season_id: 1, team_id: 1, opponent_team_id: 1, home_match: true, start_at: "17.04.2010 14:00"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    competition   = insert(:competition)
    season        = insert(:season)
    team          = insert(:team)
    opponent_team = insert(:opponent_team)
    {:ok, start_at} = Timex.parse(@valid_attrs[:start_at], "%d.%m.%Y %H:%M", :strftime)
    valid_attrs = %{@valid_attrs | competition_id: competition.id, season_id: season.id, team_id: team.id, opponent_team_id: opponent_team.id, start_at: start_at}
    changeset = Match.changeset(%Match{}, valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Match.changeset(%Match{}, @invalid_attrs)
    refute changeset.valid?
    assert changeset.errors[:competition_id] == {"can't be blank", []}
    assert changeset.errors[:season_id] == {"can't be blank", []}
    assert changeset.errors[:team_id] == {"can't be blank", []}
    assert changeset.errors[:opponent_team_id] == {"can't be blank", []}
    assert changeset.errors[:start_at] == {"can't be blank", []}
  end

  test "match is finished" do
    match = %Match{}
    assert not Match.finished?(match)

    inserted_at = Timex.local

    match = %Match{inserted_at: inserted_at, start_at: inserted_at, team_goals: 1}
    assert not Match.finished?(match)

    match = %Match{inserted_at: inserted_at, start_at: inserted_at, team_goals: 1, opponent_team_goals: 0}
    assert Match.finished?(match)

    match = %Match{inserted_at: inserted_at, start_at: inserted_at}
    assert not Match.finished?(match)

    # match has been started two hours ago
    seconds = Timex.Duration.to_seconds(Timex.Duration.from_hours(-4)) - 1
    start_at = Timex.add(inserted_at, {0, seconds, 0})
    match = %Match{inserted_at: inserted_at, start_at: start_at}
    assert Match.finished?(match)
  end

  test "match is in progress" do
    inserted_at = Timex.local

    # match starts in an 1 hour
    start_at = Timex.add(Timex.local, Timex.Duration.from_hours(1))
    match = %Match{inserted_at: inserted_at, start_at: start_at}
    assert not Match.in_progress?(match)

    # match has been started one hour ago
    start_at = Timex.add(Timex.local, Timex.Duration.from_hours(-1))
    match = %Match{inserted_at: inserted_at, start_at: start_at}
    assert Match.in_progress?(match)

    # match has been started two hours ago
    seconds = Timex.Duration.to_seconds(Timex.Duration.from_hours(-4)) - 1
    start_at = Timex.add(Timex.local,  {0, seconds, 0})
    match = %Match{inserted_at: inserted_at, start_at: start_at}
    assert not Match.in_progress?(match)
  end

  test "match needs a decision" do
    competition1 = insert(:competition, matches_need_decition: false)
    match1 = insert(:match, competition_id: competition1.id)
    assert Match.needs_decision?(match1) == false

    competition2 = insert(:competition, matches_need_decition: true)
    match2 = insert(:match, competition_id: competition2.id)
    assert Match.needs_decision?(match2) == true
  end

  test "validate goals with failure_reason is 'aborted'" do
    attrs = Map.put(@valid_attrs, :failure_reason, "aborted")
    changeset = Match.changeset(%Match{}, attrs)
    assert changeset.errors[:team_goals] == {"can't be blank", []}
    assert changeset.errors[:opponent_team_goals] == {"can't be blank", []}
  end

  test "validate goals with failure_reason other than 'aborted'" do
    attrs = Map.put(@valid_attrs, :failure_reason, "canceled")
    changeset = Match.changeset(%Match{}, attrs)
    assert changeset.errors[:team_goals] == nil
    assert changeset.errors[:opponent_team_goals] == nil
  end
end
