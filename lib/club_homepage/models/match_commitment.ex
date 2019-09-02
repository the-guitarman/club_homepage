defmodule ClubHomepage.MatchCommitment do
  use ClubHomepageWeb, :model

  alias ClubHomepage.Repo
  alias ClubHomepage.User
  alias ClubHomepageWeb.UserRole

  schema "match_commitments" do
    field :commitment, :integer

    belongs_to :match, ClubHomepage.Match
    belongs_to :user, ClubHomepage.User

    timestamps([type: :utc_datetime])
  end

  @required_fields ~w(match_id user_id commitment)a

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  @spec changeset( ClubHomepage.StandardTeamPlayer, Map ) :: Ecto.Changeset
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @required_fields)
    |> validate_required(@required_fields)
    |> foreign_key_constraint(:match_id)
    |> foreign_key_constraint(:user_id)
    |> unique_constraint(:user_id, name: "match_commitments_match_id_user_id_index")
    |> validate_user_is_a_player()
  end

  defp validate_user_is_a_player(changeset) do
    user_id = get_field(changeset, :user_id)
    user = get_user(user_id)
    cond do
      user != nil && UserRole.has_role?(user, "player") == false ->
        add_error(changeset, :user_id, gettext("needs_to_be_a_player"))
      true ->
        changeset
    end
  end

  defp get_user(user_id) when is_integer(user_id) do
    Repo.get(User, user_id)
  end
  defp get_user(_) do
    nil
  end
end
