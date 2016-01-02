defmodule ClubHomepage.OpponentTeamTest do
  use ClubHomepage.ModelCase

  alias ClubHomepage.OpponentTeam

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
end
