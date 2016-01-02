defmodule ClubHomepage.Match do
  use ClubHomepage.Web, :model

  schema "matches" do
    field :start_at, Timex.Ecto.DateTime
    field :home_match, :boolean, default: false
    
    belongs_to :season, ClubHomepage.Season
    belongs_to :team, ClubHomepage.Team
    belongs_to :opponent_team, ClubHomepage.OpponentTeam
    belongs_to :meeting_point, ClubHomepage.MeetingPoint

    timestamps
  end

  @required_fields ~w(start_at home_match)
  @optional_fields ~w()

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end
end
