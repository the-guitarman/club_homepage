defmodule ClubHomepage.SponsorImageTest do
  use ClubHomepage.ModelCase

  alias ClubHomepage.SponsorImage

  @valid_attrs %{attachment: %Plug.Upload{content_type: "image/jpeg", filename: "test_image.jpg", path: "test/support/images/test_image.jpg"}, name: "test image"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = SponsorImage.changeset(%SponsorImage{}, @valid_attrs)
    assert changeset.valid?

    {:ok, sponsor_image} = Repo.insert(changeset)
    assert sponsor_image.id == get_highest_id(SponsorImage)
  end

  test "changeset with invalid attributes" do
    changeset = SponsorImage.changeset(%SponsorImage{}, @invalid_attrs)
    refute changeset.valid?
  end
end
