defmodule ClubHomepage.TeamImageTest do
  use ClubHomepage.ModelCase

  alias ClubHomepage.TeamImage

  import ClubHomepage.Factory

  @valid_attrs %{team_id: 0, year: 2016, attachment: %Plug.Upload{content_type: "image/jpeg", filename: "test_image.jpg", path: "test/support/images/test_image.jpg"}, description: "some content"}
  @invalid_attrs %{}

  setup do
    team = insert(:team)
    valid_attrs = %{@valid_attrs | team_id: team.id}
    {:ok, valid_attrs: valid_attrs}
  end

  test "changeset with valid attributes", %{valid_attrs: valid_attrs} do
    changeset = TeamImage.changeset(%TeamImage{}, valid_attrs)
    assert changeset.valid? 

    {:ok, team_image} = Repo.insert(changeset)
    assert team_image.id == get_highest_id(TeamImage)
  end

  test "changeset with invalid attributes" do
    changeset = TeamImage.changeset(%TeamImage{}, @invalid_attrs)
    refute changeset.valid?
  end

  test "year is within founding year and the current year" do
    start_year = Application.get_env(:club_homepage, :common)[:founding_year]
    %{year: current_year} = Timex.local

    valid_attrs = %{@valid_attrs | year: start_year - 1}
    changeset = TeamImage.changeset(%TeamImage{}, valid_attrs)
    refute changeset.valid?

    for year <- start_year..current_year do
      valid_attrs = %{@valid_attrs | year: year}
      changeset = TeamImage.changeset(%TeamImage{}, valid_attrs)
      assert changeset.valid?
    end

    invalid_attrs = %{@valid_attrs | year: current_year + 1}
    changeset = TeamImage.changeset(%TeamImage{}, invalid_attrs)
    refute changeset.valid?
  end
end
