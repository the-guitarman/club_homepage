defmodule ClubHomepage.FussballDeData.SeasonTeamTable do
  use ClubHomepageWeb, :club_homepage_model
  use Ecto.Schema

  import Ecto.Changeset

  alias ClubHomepage.Season
  alias ClubHomepage.Team

  schema "season_team_tables" do
    # field :season_id, :id
    # field :team_id, :id

    field :html, :string

    timestamps()

    belongs_to :season, Season
    belongs_to :team, Team
  end

  @required_fields ~w(season_id team_id html)a

  @doc false
  def changeset(season_team_table, attrs) do
    season_team_table
    |> cast(attrs, @required_fields)
    |> validate_required(@required_fields)
    |> foreign_key_constraint(:season_id)
    |> foreign_key_constraint(:team)
    |> unique_constraint(:season_id, name: "unique_season_team_tables_index")
  end
end
