defmodule ClubHomepage.TeamTest do
  use ClubHomepage.ModelCase

  alias ClubHomepage.Team

  import ClubHomepage.Factory

  @valid_attrs %{competition_id: 1, name: "This is my    team without ß in the name."}
  @invalid_attrs %{}

  test "create a team" do
    competition = insert(:competition)
    valid_attrs = %{@valid_attrs | competition_id: competition.id}

    changeset = Team.changeset(%Team{}, valid_attrs)
    assert changeset.valid?
    assert changeset.changes.slug == "this-is-my-team-without-ss-in-the-name"

    {:ok, team} = Repo.insert(changeset)
    assert team.slug == "this-is-my-team-without-ss-in-the-name"

    {:error, changeset} =
      Team.changeset(%Team{}, valid_attrs)
      |> Repo.insert()

    refute changeset.valid?
    assert changeset.errors[:name] == {"has already been taken", [constraint: :unique, constraint_name: "teams_name_index"]}
  end

  test "edit a team" do
    team1 = insert(:team)
    team2 = insert(:team)

    changeset = Team.changeset(team2, %{name: "new team name"})
    {:ok, team} = Repo.update(changeset)

    assert team.name == "new team name"

    {:error, changeset} =
      Team.changeset(team2, %{name: team1.name})
      |> Repo.update()
    refute changeset.valid?
    assert changeset.errors[:name] == {"has already been taken", [constraint: :unique, constraint_name: "teams_name_index"]}
    #assert changeset.errors[:slug] == nil #"already exists"
  end

  test "changeset with invalid attributes" do
    changeset = Team.changeset(%Team{}, @invalid_attrs)
    refute changeset.valid?
    assert changeset.errors[:competition_id] == {"can't be blank", [validation: :required]}
    assert changeset.errors[:name] == {"can't be blank", [validation: :required]}
  end
end
