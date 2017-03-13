defmodule ClubHomepage.BeerListTest do
  use ClubHomepage.ModelCase

  alias ClubHomepage.BeerList

  @valid_attrs %{}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = BeerList.changeset(%BeerList{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = BeerList.changeset(%BeerList{}, @invalid_attrs)
    refute changeset.valid?
  end
end
