defmodule ClubHomepage.StandardTeamPlayerTest do
  use ClubHomepage.ModelCase

  # alias Ecto.Changeset
  # alias ClubHomepage.Team
  # alias ClubHomepage.User
  alias ClubHomepage.StandardTeamPlayer

  import ClubHomepage.Factory

  @valid_attrs %{team_id: 1, user_id: 1}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    team = insert(:team)
    user = insert(:user)
    valid_attrs = %{@valid_attrs | team_id: team.id, user_id: user.id}
    changeset = StandardTeamPlayer.changeset(%StandardTeamPlayer{}, valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = StandardTeamPlayer.changeset(%StandardTeamPlayer{}, @invalid_attrs)
    refute changeset.valid?
  end
end
