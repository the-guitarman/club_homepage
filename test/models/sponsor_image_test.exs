defmodule ClubHomepage.SponsorImageTest do
  use ClubHomepage.ModelCase

  alias ClubHomepage.SponsorImage

  @valid_attrs %{attachment: "test/support/images/test_image.jpg", name: "test image"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = SponsorImage.changeset(%SponsorImage{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = SponsorImage.changeset(%SponsorImage{}, @invalid_attrs)
    refute changeset.valid?
  end
end
