defmodule ClubHomepage.MeetingPointTest do
  use ClubHomepage.ModelCase

  alias ClubHomepage.MeetingPoint

  import ClubHomepage.Factory

  @valid_attrs %{name: "Club House", address_id: 1}
  @invalid_attrs %{address_id: -1}

  test "changeset with valid attributes" do
    address = insert(:address)
    valid_attrs = %{@valid_attrs | address_id: address.id}
    changeset = MeetingPoint.changeset(%MeetingPoint{}, valid_attrs)
    assert changeset.valid?

    {:ok, meeting_point} = Repo.insert(changeset)
    assert meeting_point.name == "Club House"
  end

  test "changeset with invalid attributes" do
    {:error, changeset} =
      MeetingPoint.changeset(%MeetingPoint{}, @invalid_attrs)
      |> Repo.insert()
    refute changeset.valid?
    assert changeset.errors[:address_id] == {"does not exist", []}
  end
end
