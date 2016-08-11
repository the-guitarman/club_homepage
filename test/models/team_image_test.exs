defmodule ClubHomepage.TeamImageTest do
  use ClubHomepage.ModelCase

  alias ClubHomepage.TeamImage

  import ClubHomepage.Factory

  @valid_attrs %{team_id: 0, year: 2016, attachment: "test/support/images/test_image.jpg", description: "some content"}
  @invalid_attrs %{}

  setup do
    team = create(:team)
    valid_attrs = %{@valid_attrs | team_id: team.id}
    {:ok, valid_attrs: valid_attrs}
  end

  test "changeset with valid attributes", %{valid_attrs: valid_attrs} do
    changeset = TeamImage.changeset(%TeamImage{}, valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = TeamImage.changeset(%TeamImage{}, @invalid_attrs)
    refute changeset.valid?
  end
end
