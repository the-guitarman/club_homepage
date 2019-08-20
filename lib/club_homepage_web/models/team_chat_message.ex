defmodule ClubHomepage.TeamChatMessage do
  use ClubHomepage.Web, :model

  schema "team_chat_messages" do
    field :message, :string
    belongs_to :team, ClubHomepage.Team
    belongs_to :user, ClubHomepage.User

    timestamps([type: :utc_datetime])
  end

  @required_fields [:team_id, :user_id, :message]

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @required_fields)
    |> validate_required(@required_fields)
  end
end
