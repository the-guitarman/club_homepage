defmodule ClubHomepage.Match do
  use ClubHomepage.Web, :model

  alias ClubHomepage.ModelValidator

  schema "matches" do
    field :start_at, Timex.Ecto.DateTime
    field :home_match, :boolean, default: false
    field :team_goals, :integer
    field :opponent_team_goals, :integer
    field :json, :string, virtual: true

    belongs_to :competition, ClubHomepage.Competition
    belongs_to :season, ClubHomepage.Season
    belongs_to :team, ClubHomepage.Team
    belongs_to :opponent_team, ClubHomepage.OpponentTeam
    belongs_to :meeting_point, ClubHomepage.MeetingPoint

    timestamps
  end

  @required_fields ~w(competition_id season_id team_id opponent_team_id start_at home_match)
  @optional_fields ~w(meeting_point_id team_goals opponent_team_goals)

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  @spec changeset( ClubHomepage.Match, Map ) :: Ecto.Changeset
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> ModelValidator.foreign_key_constraint(:competition_id)
    |> ModelValidator.foreign_key_constraint(:season_id)
    |> ModelValidator.foreign_key_constraint(:team_id)
    |> ModelValidator.foreign_key_constraint(:opponent_team_id)
    |> ModelValidator.validate_uniqueness([:season_id, :team_id, :opponent_team_id, :home_match], name: "unique_match_index")
  end


  @doc """
  Returns true after two hours from match start. Otherwise false.
  """
  @spec finished?( ClubHomepage.Match ) :: Boolean
  def finished?(match) do
    match_end_at = Timex.Date.add(match.start_at, Timex.Time.to_timestamp(2, :hours))
    match_end_at < Timex.Date.local
  end
end
