defmodule ClubHomepage.StandardTeamPlayer do
  use ClubHomepage.Web, :model

  schema "standard_team_players" do
    belongs_to :team, ClubHomepage.Team
    belongs_to :user, ClubHomepage.User

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, ~w(team_id user_id))
    |> validate_required([:team_id, :user_id])
    |> foreign_key_constraint(:team_id)
    |> foreign_key_constraint(:user_id)
  end
end
