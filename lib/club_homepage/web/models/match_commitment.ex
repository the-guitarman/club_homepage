defmodule ClubHomepage.MatchCommitment do
  use ClubHomepage.Web, :model

  schema "match_commitments" do
    belongs_to :match, ClubHomepage.Match
    belongs_to :user, ClubHomepage.User

    timestamps()
  end


  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, ~w(match_id user_id))
    |> validate_required([:match_id, :user_id])
    |> foreign_key_constraint(:match_id)
    |> foreign_key_constraint(:user_id)
  end
end
