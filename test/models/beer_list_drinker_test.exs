defmodule ClubHomepage.BeerListDrinkerTest do
  use ClubHomepage.ModelCase

  alias ClubHomepage.BeerListDrinker

  import ClubHomepage.Factory

  @valid_attrs %{beer_list_id: 1, user_id: 1, beers: 42}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    beer_list = insert(:beer_list)
    user = insert(:user)
    valid_attrs = %{@valid_attrs | beer_list_id: beer_list.id, user_id: user.id}

    changeset = BeerListDrinker.changeset(%BeerListDrinker{}, valid_attrs)
    assert changeset.valid?
    assert Enum.empty?(changeset.errors)
  end

  test "changeset with invalid attributes" do
    changeset = BeerListDrinker.changeset(%BeerListDrinker{}, @invalid_attrs)
    refute changeset.valid?
    assert Enum.count(changeset.errors) == 3
    assert changeset.errors[:beer_list_id] == {"can't be blank", []}
    assert changeset.errors[:user_id] == {"can't be blank", []}
    assert changeset.errors[:beers] == {"can't be blank", []}
  end
end
