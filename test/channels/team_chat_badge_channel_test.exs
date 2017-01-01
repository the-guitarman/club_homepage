defmodule ClubHomepage.TeamChatBadgeChannelTest do
  use ClubHomepage.ChannelCase

  alias ClubHomepage.TeamChatBadgeChannel

  import ClubHomepage.Factory
  import Ecto.Query, only: [from: 2]

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
  end
end
