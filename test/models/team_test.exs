defmodule ClubHomepage.TeamTest do
  use ClubHomepage.ModelCase

  alias ClubHomepage.Team

  @valid_attrs %{name: "This is my    team without ß in the name."}

  test "create a team" do
    changeset = Team.changeset(%Team{}, @valid_attrs)
    assert changeset.valid?
    assert changeset.changes.rewrite == "this-is-my-team-without-ss-in-the-name"

    {:ok, team} = Repo.insert(changeset)
    assert team.rewrite == "this-is-my-team-without-ss-in-the-name"

    changeset = Team.changeset(%Team{}, @valid_attrs)
    refute changeset.valid?
    assert changeset.errors[:rewrite] == "ist bereits vergeben"
  end
end
