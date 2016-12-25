defmodule ClubHomepage.UserMetaDataTest do
  use ClubHomepage.ModelCase
  use ExUnit.Case

  alias ClubHomepage.UserMetaData

  import ClubHomepage.Factory
  #import Ecto.Query, only: [from: 2]

  test "save last read team chat message id" do
    team = insert(:team)
    user = insert(:user)

    assert user.meta_data == nil
    assert UserMetaData.last_read_team_chat_message_id(team.id, user) == nil
    assert UserMetaData.unread_team_chat_messages_number(team.id, user) == 0
    assert Enum.count(UserMetaData.unread_team_chat_messages(team.id, user)) == 0

    message_1 = insert(:team_chat_message, team_id: team.id, user_id: user.id)
    message_2 = insert(:team_chat_message, team_id: team.id, user_id: user.id)
    message_3 = insert(:team_chat_message, team_id: team.id, user_id: user.id)
    assert message_1.id < message_2.id
    assert message_2.id < message_3.id

    {:ok, updated_user} = UserMetaData.save_last_read_team_chat_message_id(team.id, message_2.id, user)

    assert updated_user.meta_data["last_read_team_chat_message_ids"][Integer.to_string(team.id)] == message_2.id
    assert UserMetaData.last_read_team_chat_message_id(team.id, updated_user) == message_2.id
    assert UserMetaData.unread_team_chat_messages_number(team.id, updated_user) == 1
    assert Enum.count(UserMetaData.unread_team_chat_messages(team.id, updated_user)) == 1

    [unread_message] = UserMetaData.unread_team_chat_messages(team.id, updated_user)
    assert unread_message.id == message_3.id
  end
end
