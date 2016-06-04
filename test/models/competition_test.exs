defmodule ClubHomepage.CompetitionTest do
  use ClubHomepage.ModelCase

  alias ClubHomepage.Competition

  import ClubHomepage.Factory

  @valid_attrs %{name: "some content", matches_need_decition: false}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Competition.changeset(%Competition{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Competition.changeset(%Competition{}, @invalid_attrs)
    refute changeset.valid?
  end

  test "edit a competition" do
    competition1 = create(:competition)
    competition2 = create(:competition)

    changeset = Competition.changeset(competition2, %{name: "new competition name"})
    {:ok, competition} = Repo.update(changeset)

    assert competition.name == "new competition name"

    changeset = Competition.changeset(competition2, %{name: competition1.name})
    {:error, _errors} = Repo.update(changeset)
    refute changeset.valid?
    assert changeset.errors[:name] == "already exists"
  end
end
