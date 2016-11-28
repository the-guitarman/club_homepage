defmodule ClubHomepage.UserMetaDataTest do
  use ClubHomepage.ModelCase
  use ExUnit.Case

  alias ClubHomepage.Repo
  alias ClubHomepage.User
  alias ClubHomepage.Team
  #alias ClubHomepage.TeamChatMessage

  import ClubHomepage.Factory
  #import Ecto.Query, only: [from: 2]

  test "save last read team chat message id" do
    team = insert(:team)
    user = insert(:user)

    assert user.meta_data == nil

    message_1 = insert(:team_chat_message, team_id: team.id, user_id: user.id)
    message_2 = insert(:team_chat_message, team_id: team.id, user_id: user.id)
    message_3 = insert(:team_chat_message, team_id: team.id, user_id: user.id)
    assert message_1.id < message_2.id
    assert message_2.id < message_3.id

    {:ok, updated_user} = ClubHomepage.UserMetaData.save_last_read_team_chat_message_id(team.id, message_2.id, user)

    assert updated_user.meta_data[:last_read_team_chat_message_ids][Integer.to_string(team.id)] == message_2.id
  end

  # test "unread team chat messages for the user" do
  #   team = insert(:team)
  #   user = insert(:user)

  #   messages = ClubHomepage.UserMetaData.unread_team_chat_messages(team.id, user)
  #   assert messages == []

  #   message_1 = insert(:team_chat_message, team_id: team.id, user_id: user.id)

  #   [message | _tail] = ClubHomepage.UserMetaData.unread_team_chat_messages(team.id, user)
  #   assert message.message == message_1.message
  # end
end
