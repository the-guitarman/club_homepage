defmodule ClubHomepage.MeetingPointTest do
  use ClubHomepage.ModelCase

  alias ClubHomepage.MeetingPoint

  @valid_attrs %{name: "Club House", address_id: 1}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = MeetingPoint.changeset(%MeetingPoint{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = MeetingPoint.changeset(%MeetingPoint{}, @invalid_attrs)
    refute changeset.valid?
  end
end
