defmodule ClubHomepage.StandardTeamPlayer do
  use ClubHomepage.Web, :model

  alias ClubHomepage.Repo
  alias ClubHomepage.User
  alias ClubHomepage.Web.UserRole

  schema "standard_team_players" do
    belongs_to :team, ClubHomepage.Team
    belongs_to :user, ClubHomepage.User

    field :standard_shirt_number, :integer

    timestamps([type: :utc_datetime])
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  @spec changeset( ClubHomepage.StandardTeamPlayer, Map ) :: Ecto.Changeset
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, ~w(team_id user_id standard_shirt_number)a)
    |> validate_required([:team_id, :user_id])
    |> foreign_key_constraint(:team_id)
    |> foreign_key_constraint(:user_id)
    |> unique_constraint(:user_id, name: "standard_team_players_team_id_user_id_index")
    |> validate_user_is_a_player()
    |> validate_standard_shirt_number()
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

  defp validate_standard_shirt_number(changeset) do
    case get_field(changeset, :standard_shirt_number) do
      nil -> changeset
      _number ->
        changeset
        |> validate_number(:standard_shirt_number, greater_than: 0, less_than: 100)
        |> unique_constraint(:standard_shirt_number, name: :index_standard_shirt_number_on_team_id)
    end
  end

  defp get_user(user_id) when is_integer(user_id) do
    Repo.get(User, user_id)
  end
  defp get_user(_) do
    nil
  end
end
