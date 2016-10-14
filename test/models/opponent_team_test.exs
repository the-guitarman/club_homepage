defmodule ClubHomepage.OpponentTeamTest do
  use ClubHomepage.ModelCase

  alias ClubHomepage.OpponentTeam

  import ClubHomepage.Factory

  @valid_attrs %{name: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = OpponentTeam.changeset(%OpponentTeam{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = OpponentTeam.changeset(%OpponentTeam{}, @invalid_attrs)
    refute changeset.valid?
  end

  test "edit an opponent team" do
    opponent_team_1 = insert(:opponent_team)
    opponent_team_2 = insert(:opponent_team)

    {:ok, competition} =
      OpponentTeam.changeset(opponent_team_2, %{name: "new competition name"})
      |> Repo.update()

    assert competition.name == "new competition name"

    {:error, changeset} =
      OpponentTeam.changeset(opponent_team_2, %{name: opponent_team_1.name})
      |> Repo.update()

    refute changeset.valid?
    assert changeset.errors[:name] == {"has already been taken", []}
  end
end
