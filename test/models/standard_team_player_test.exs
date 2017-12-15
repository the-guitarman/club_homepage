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


    {:error, changeset} = Repo.insert(changeset)
    assert changeset.errors[:user_id] == {"has already been taken", []}
  end
end
