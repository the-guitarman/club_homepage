defmodule ClubHomepage.AddressTest do
  use ClubHomepage.ModelCase

  alias ClubHomepage.Address

  @valid_attrs %{city: "some content", district: "some content", street: "some content", zip_code: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Address.changeset(%Address{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Address.changeset(%Address{}, @invalid_attrs)
    refute changeset.valid?
  end
end
