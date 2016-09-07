defmodule ClubHomepage.TeamChatMessageTest do
  use ClubHomepage.ModelCase

  alias ClubHomepage.TeamChatMessage

  @valid_attrs %{message: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = TeamChatMessage.changeset(%TeamChatMessage{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = TeamChatMessage.changeset(%TeamChatMessage{}, @invalid_attrs)
    refute changeset.valid?
  end
end
