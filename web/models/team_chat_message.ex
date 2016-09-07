defmodule ClubHomepage.TeamChatMessage do
  use ClubHomepage.Web, :model

  schema "team_chat_messages" do
    field :message, :string
    belongs_to :team, ClubHomepage.Team
    belongs_to :user, ClubHomepage.User

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:message])
    |> validate_required([:message])
  end
end
