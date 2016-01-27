defmodule ClubHomepage.SeasonTest do
  use ClubHomepage.ModelCase

  alias ClubHomepage.Season

  @valid_attrs %{name: "2015-2016"}
  @invalid_attrs %{name: "some name"}

  test "changeset with valid attributes" do
    changeset = Season.changeset(%Season{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Season.changeset(%Season{}, @invalid_attrs)
    refute changeset.valid?
  end
end
