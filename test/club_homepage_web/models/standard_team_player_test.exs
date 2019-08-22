defmodule ClubHomepage.StandardTeamPlayerTest do
  use ClubHomepage.ModelCase

  alias ClubHomepage.StandardTeamPlayer

  import ClubHomepage.Factory

  @invalid_attrs %{}

  test "changeset with invalid attributes" do
    changeset = StandardTeamPlayer.changeset(%StandardTeamPlayer{}, @invalid_attrs)
    refute changeset.valid?
  end

  test "user needs to be a player" do
    team = insert(:team)
    user = insert(:user, roles: "member")

    changeset = StandardTeamPlayer.changeset(%StandardTeamPlayer{}, %{team_id: team.id, user_id: user.id})

    refute changeset.valid?
  end

  test "user is a player and is unique" do
    team = insert(:team)
    user = insert(:user, roles: "member player")

    changeset = StandardTeamPlayer.changeset(%StandardTeamPlayer{}, %{team_id: team.id, user_id: user.id})

    assert changeset.valid?

    {:ok, standard_team_player} = Repo.insert(changeset)
    assert standard_team_player.team_id == team.id
    assert standard_team_player.user_id == user.id
    assert standard_team_player.standard_shirt_number == nil


    {:error, changeset} = Repo.insert(changeset)
    assert changeset.errors[:user_id] == {"has already been taken", [constraint: :unique, constraint_name: "standard_team_players_team_id_user_id_index"]}
  end

  test "standard_shirt_number is unique per team" do
    ssn = insert(:standard_team_player, standard_shirt_number: 13)
    user = insert(:user)

    changeset = StandardTeamPlayer.changeset(%StandardTeamPlayer{}, %{team_id: ssn.team_id, user_id: user.id, standard_shirt_number: 13})

    assert changeset.valid?

    {:error, changeset} = Repo.insert(changeset)
    refute changeset.valid?
    assert changeset.errors[:standard_shirt_number] == {"has already been taken", [constraint: :unique, constraint_name: "index_standard_shirt_number_on_team_id"]}
  end
end
