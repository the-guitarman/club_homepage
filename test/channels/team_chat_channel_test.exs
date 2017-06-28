defmodule ClubHomepage.TeamChatChannelTest do
  use ClubHomepage.Web.ChannelCase

  alias ClubHomepage.Repo
  alias ClubHomepage.Web.TeamChatChannel
  alias ClubHomepage.TeamChatMessage
  alias ClubHomepage.User

  import ClubHomepage.Factory
  import Ecto.Query, only: [from: 2]

  setup do
    user = insert(:user)
    team = insert(:team)
    {:ok, _, socket} =
      socket("users_socket: #{user.id}", %{current_user: user})
      |> subscribe_and_join(TeamChatChannel, "team-chats:#{team.id}")

    {:ok, socket: socket}
  end

  test "new chat message replies with status ok", %{socket: socket} do
    assert count() == 0
    ref = push socket, "message:add", %{"message" => "Hello!"}
    assert_reply ref, :ok
    assert count() == 1
  end

  test "new chat message broadcasts to team-chats:<team_id>", %{socket: socket} do
    push socket, "message:add", %{"message" => "Hi"}
    assert_broadcast "message:added", %{chat_message: %{"message" => "Hi"}}
  end

  test "new chat messages has been seen for team-chats:<team_id>", %{socket: socket} do
    team_id = socket.assigns.team_id
    current_user_id = socket.assigns.current_user.id
    user = Repo.get!(User, current_user_id)
    assert user.meta_data == nil
    ref = push socket, "message:seen", %{"message_id" => 72}
    #:timer.sleep(:timer.seconds(1))
    assert_reply ref, :ok
    user = Repo.get!(User, current_user_id)
    assert user.meta_data["last_read_team_chat_message_ids"][Integer.to_string(team_id)] == 72
  end

  test "broadcasts are pushed to the client", %{socket: socket} do
    broadcast_from! socket, "broadcast", %{"some" => "data"}
    assert_push "broadcast", %{"some" => "data"}
  end

  defp count do
    from(tcm in TeamChatMessage, select: count(tcm.id))
    |> Repo.one()
  end
end
