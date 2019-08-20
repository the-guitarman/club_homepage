defmodule ClubHomepage.TeamChatMessageTest do
  use ClubHomepage.ModelCase

  alias ClubHomepage.TeamChatMessage

  import ClubHomepage.Factory

  @valid_attrs %{team_id: 0, user_id: 0, message: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = TeamChatMessage.changeset(%TeamChatMessage{}, valid_attrs())
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = TeamChatMessage.changeset(%TeamChatMessage{}, @invalid_attrs)
    refute changeset.valid?
    assert changeset.errors[:team_id] == {"can't be blank", [validation: :required]}
    assert changeset.errors[:user_id] == {"can't be blank", [validation: :required]}
    assert changeset.errors[:message] == {"can't be blank", [validation: :required]}
  end

  defp valid_attrs do
    team = insert(:team)
    user = insert(:user)
    %{@valid_attrs | team_id: team.id, user_id: user.id}
  end
end
