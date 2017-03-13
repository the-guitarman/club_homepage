defmodule ClubHomepage.BeerListDrinkerTest do
  use ClubHomepage.ModelCase

  alias ClubHomepage.BeerListDrinker

  @valid_attrs %{beers: 42}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = BeerListDrinker.changeset(%BeerListDrinker{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = BeerListDrinker.changeset(%BeerListDrinker{}, @invalid_attrs)
    refute changeset.valid?
  end
end
