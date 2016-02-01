defmodule ClubHomepage.MeetingPointTest do
  use ClubHomepage.ModelCase

  alias ClubHomepage.MeetingPoint

  import ClubHomepage.Factory

  @valid_attrs %{name: "Club House", address_id: 1}
  @invalid_attrs %{address_id: -1}

  test "changeset with valid attributes" do
    address = create(:address)
    valid_attrs = %{@valid_attrs | address_id: address.id}
    changeset = MeetingPoint.changeset(%MeetingPoint{}, valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = MeetingPoint.changeset(%MeetingPoint{}, @invalid_attrs)
    refute changeset.valid?
    assert changeset.errors[:address_id] == "does not exist"
  end
end
