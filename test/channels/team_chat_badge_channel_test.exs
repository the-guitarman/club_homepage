defmodule ClubHomepage.TeamChatBadgeChannelTest do
  use ClubHomepage.Web.ChannelCase

  alias ClubHomepage.Web.TeamChatBadgeChannel

  import ClubHomepage.Factory

  setup do
    user = insert(:user)
    team = insert(:team)
    {:ok, response, socket} =
      socket("users_socket: #{user.id}", %{current_user: user})
      |> subscribe_and_join(TeamChatBadgeChannel, "team-chat-badges:#{team.id}")

    {:ok, socket: socket, response: response}
  end

  test "join with status ok", %{socket: socket, response: response} do
    current_user = socket.assigns.current_user
    assert response == %{"current_user_id" => current_user.id, "unread_team_chat_messages_number" => 0}
    leave_socket(socket)
  end
end
