defmodule ClubHomepage.BeerListTest do
  use ClubHomepage.ModelCase

  alias ClubHomepage.BeerList

  @valid_attrs %{title: "Team 1", price_per_beer: 1.5}
  @invalid_attrs %{title: "", price_per_beer: nil}

  test "changeset with valid attributes" do
    changeset = BeerList.changeset(%BeerList{}, @valid_attrs)
    assert changeset.valid?
    assert Enum.empty?(changeset.errors)
  end

  test "changeset with invalid attributes" do
    changeset = BeerList.changeset(%BeerList{}, @invalid_attrs)
    changeset.valid?
    refute changeset.valid?
    assert changeset.errors[:title] == {"can't be blank", []}
    assert changeset.errors[:price_per_beer] == {"can't be blank", []}
  end
end
