defmodule ClubHomepage.Match do
  use ClubHomepage.Web, :model

  alias ClubHomepage.ModelValidator

  import ClubHomepage.Extension.CommonMatch, only: [failure_reasons: 0]

  schema "matches" do
    field :start_at, Timex.Ecto.DateTime
    field :home_match, :boolean, default: false
    field :team_goals, :integer
    field :opponent_team_goals, :integer
    field :failure_reason, :string
    field :description, :string
    field :match_events, :string, default: "[]"

    field :json, :string, virtual: true

    belongs_to :competition, ClubHomepage.Competition
    belongs_to :season, ClubHomepage.Season
    belongs_to :team, ClubHomepage.Team
    belongs_to :opponent_team, ClubHomepage.OpponentTeam
    belongs_to :meeting_point, ClubHomepage.MeetingPoint

    timestamps
  end

  @required_fields ~w(competition_id season_id team_id opponent_team_id start_at home_match)
  @optional_fields ~w(meeting_point_id team_goals opponent_team_goals failure_reason description match_events)

  @doc """ 
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  @spec changeset( ClubHomepage.Match, Map ) :: Ecto.Changeset
  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> ModelValidator.foreign_key_constraint(:competition_id)
    |> ModelValidator.foreign_key_constraint(:season_id)
    |> ModelValidator.foreign_key_constraint(:team_id)
    |> ModelValidator.foreign_key_constraint(:opponent_team_id)
    |> ModelValidator.validate_uniqueness([:season_id, :team_id, :opponent_team_id, :home_match], name: "unique_match_index")
    |> validate_inclusion(:failure_reason, [nil | failure_reasons])
    |> validate_team_goals
    |> validate_opponent_team_goals
  end

  def validate_team_goals(changeset) do
    failure_reasons = get_field(changeset, :failure_reason)
    goals           = get_field(changeset, :team_goals)
    cond do
      failure_reasons == "aborted" && goals == nil ->
        add_error(changeset, :team_goals, "can't be blank")
      true ->
        changeset
    end
  end

  def validate_opponent_team_goals(changeset) do
    failure_reasons = get_field(changeset, :failure_reason)
    goals           = get_field(changeset, :opponent_team_goals)
    cond do
      failure_reasons == "aborted" && goals == nil ->
        add_error(changeset, :opponent_team_goals, "can't be blank")
      true -> changeset
    end
  end

  @doc """
  Returns true after two hours from match start. Otherwise false.
  """
  @spec finished?( ClubHomepage.Match ) :: Boolean
  def finished?(match) do
    #TODO: read the match end datetime from the timeline events
    # has goals?
    # finished flag?
    # no failure reason
    match_end_at = Timex.Date.add(match.start_at, Timex.Time.to_timestamp(4, :hours))
    match_end_at < Timex.Date.local
  end

  @doc """
  Returns true if the match has been started and it's not finished. Otherwise false.
  """
  @spec in_progress?( ClubHomepage.Match ) :: Boolean
  def in_progress?(match) do
    match.start_at < Timex.Date.local && not finished?(match)
  end
end
