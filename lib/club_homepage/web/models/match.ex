defmodule ClubHomepage.Match do
  use ClubHomepage.Web, :model

  alias ClubHomepage.Web.ModelValidator

  import ClubHomepage.Extension.CommonMatch, only: [failure_reasons: 0]

  schema "matches" do
    field :start_at, Timex.Ecto.DateTime
    field :home_match, :boolean, default: false
    field :team_goals, :integer
    field :opponent_team_goals, :integer
    field :failure_reason, :string
    field :description, :string
    field :match_events, :string, default: "[]"
    field :meeting_point_at, Timex.Ecto.DateTime
    field :uid, :string

    field :json, :string, virtual: true
    field :json_creation, :boolean, virtual: true, default: false

    belongs_to :competition, ClubHomepage.Competition
    belongs_to :season, ClubHomepage.Season
    belongs_to :team, ClubHomepage.Team
    belongs_to :opponent_team, ClubHomepage.OpponentTeam
    belongs_to :meeting_point, ClubHomepage.MeetingPoint

    timestamps()
  end

  @cast_fields ~w(competition_id season_id team_id opponent_team_id start_at home_match meeting_point_id team_goals opponent_team_goals failure_reason description match_events meeting_point_at json_creation)
  @required_fields [:competition_id, :season_id, :team_id, :opponent_team_id, :start_at, :home_match]

  @doc """ 
  Creates a changeset based on the `model` and `params`.
  
  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  @spec changeset( ClubHomepage.Match, Map ) :: Ecto.Changeset
  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @cast_fields)
    |> validate_required(@required_fields)
    |> foreign_key_constraint(:competition_id)
    |> foreign_key_constraint(:season_id)
    |> foreign_key_constraint(:team_id)
    |> foreign_key_constraint(:opponent_team_id)
    |> ModelValidator.validate_uniqueness(:json, [:competition_id, :season_id, :team_id, :opponent_team_id, :home_match])
    |> validate_inclusion(:failure_reason, [nil | failure_reasons()])
    |> validate_team_goals
    |> validate_opponent_team_goals
    |> set_uid
  end

  defp validate_team_goals(changeset) do
    failure_reasons = get_field(changeset, :failure_reason)
    goals           = get_field(changeset, :team_goals)
    cond do
      failure_reasons == "aborted" && goals == nil ->
        add_error(changeset, :team_goals, "can't be blank")
      true ->
        changeset
    end
  end

  defp validate_opponent_team_goals(changeset) do
    failure_reasons = get_field(changeset, :failure_reason)
    goals           = get_field(changeset, :opponent_team_goals)
    cond do
      failure_reasons == "aborted" && goals == nil ->
        add_error(changeset, :opponent_team_goals, "can't be blank")
      true -> changeset
    end
  end

  defp set_uid(changeset) do
    case get_field(changeset, :uid) do
      nil -> put_change(changeset, :uid, uid(changeset))
      _ -> changeset
    end
  end

  defp uid(changeset) do
    {:ok, time} = Timex.format(Timex.now, "{ISO:Extended}")
    :crypto.hash(:sha, "#{time}, #{team_ids(changeset)}, #{get_field(changeset, :competition_id)}")
    |> Base.encode16(case: :lower)
  end

  defp team_ids(changeset) do
    case get_field(changeset, :home_match) do
      true -> "#{get_field(changeset, :team_id)} - #{get_field(changeset, :opponent_team_id)}"
      _ -> "#{get_field(changeset, :opponent_team_id)} - #{get_field(changeset, :team_id)}"
    end
  end

  @doc """
  Returns true after two hours from match start. Otherwise false.
  """
  @spec finished?( ClubHomepage.Match ) :: Boolean
  def finished?(%{inserted_at: inserted_at, start_at: start_at}) when is_nil(inserted_at) or is_nil(start_at), do: false
  def finished?(%{team_goals: team_goals, opponent_team_goals: opponent_team_goals}) when is_integer(team_goals) and is_integer(opponent_team_goals), do: true
  def finished?(match) do
    #TODO: read the match end datetime from the timeline events
    # has goals?
    # finished flag?
    # no failure reason
    match_end_at = Timex.add(match.start_at, Timex.Duration.from_hours(4))
    Timex.compare(match_end_at, Timex.now) == -1
  end

  @doc """
  Returns true if the match has been started and it's not finished. Otherwise false.
  """
  @spec in_progress?( ClubHomepage.Match ) :: Boolean
  def in_progress?(match) do
    Timex.compare(match.start_at, Timex.local) == -1 && not finished?(match)
  end

  @doc """
  Returns true if the match needs a decision (extra time, penalty shoot-out). Otherwise false.
  """
  @spec needs_decision?( ClubHomepage.Match ) :: Boolean
  def needs_decision?(match) do
    competition = ClubHomepage.Repo.get!(ClubHomepage.Competition, match.competition_id)
    competition.matches_need_decition
  end
end
