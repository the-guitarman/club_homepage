defmodule ClubHomepage.CompetitionTest do
  use ClubHomepage.ModelCase

  alias ClubHomepage.Competition

  @valid_attrs %{name: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Competition.changeset(%Competition{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Competition.changeset(%Competition{}, @invalid_attrs)
    refute changeset.valid?
  end
end
