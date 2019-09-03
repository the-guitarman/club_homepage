defmodule ClubHomepage.FussballDeData.SeasonTeamTableTest do
  use ClubHomepage.ModelCase

  alias ClubHomepage.FussballDeData.SeasonTeamTable

  import ClubHomepage.Factory

  @valid_attrs %{season_id: 1, team_id: 1, html: "season team table"}
  @invalid_attrs %{season_id: nil, team_id: nil, html: ""}

  test "changeset with invalid attributes" do
    changeset = SeasonTeamTable.changeset(%SeasonTeamTable{}, @invalid_attrs)
    refute changeset.valid?
    assert changeset.errors[:season_id] == {"can't be blank", [validation: :required]}
    assert changeset.errors[:team_id] == {"can't be blank", [validation: :required]}
    assert changeset.errors[:html] == {"can't be blank", [validation: :required]}
  end

  test "uniqueness" do
    season = insert(:season)
    team = insert(:team)

    changeset = SeasonTeamTable.changeset(%SeasonTeamTable{}, %{season_id: season.id, team_id: team.id, html: "season team table"})

    assert changeset.valid?

    {:ok, season_team_table} = Repo.insert(changeset)
    assert season_team_table.season_id == season.id
    assert season_team_table.team_id == team.id
    assert season_team_table.html == "season team table"

    {:error, changeset} = Repo.insert(changeset)
    assert changeset.errors[:season_id] == {"has already been taken", [constraint: :unique, constraint_name: "unique_season_team_tables_index"]}

    team_2 = insert(:team)
    changeset_2 = SeasonTeamTable.changeset(%SeasonTeamTable{}, %{season_id: season.id, team_id: team_2.id, html: "season team table 2"})

    assert changeset_2.valid?

    {:ok, season_team_table_2} = Repo.insert(changeset_2)
    assert season_team_table_2.season_id == season.id
    assert season_team_table_2.team_id == team_2.id
    assert season_team_table_2.html == "season team table 2"
  end
end
