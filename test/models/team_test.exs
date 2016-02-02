defmodule ClubHomepage.TeamTest do
  use ClubHomepage.ModelCase

  alias ClubHomepage.Team

  import ClubHomepage.Factory

  @valid_attrs %{name: "This is my    team without ß in the name."}

  test "create a team" do
    changeset = Team.changeset(%Team{}, @valid_attrs)
    assert changeset.valid?
    assert changeset.changes.rewrite == "this-is-my-team-without-ss-in-the-name"

    {:ok, team} = Repo.insert(changeset)
    assert team.rewrite == "this-is-my-team-without-ss-in-the-name"

    changeset = Team.changeset(%Team{}, @valid_attrs)
    refute changeset.valid?
    assert changeset.errors[:rewrite] == "already exists"
  end

  test "edit a team" do
    team1 = create(:team)
    team2 = create(:team)

    changeset = Team.changeset(team2, %{name: "new team name"})
    {:ok, team} = Repo.update(changeset)

    assert team.name == "new team name"

    changeset = Team.changeset(team2, %{name: team1.name})
    {:error, _errors} = Repo.update(changeset)
    refute changeset.valid?
    assert changeset.errors[:name] == "already exists"
    #assert changeset.errors[:rewrite] == nil #"already exists"
  end
end
