defmodule ClubHomepage.TeamChatChannelTest do
  use ClubHomepage.ChannelCase

  alias ClubHomepage.TeamChatChannel
  alias ClubHomepage.TeamChatMessage

  import ClubHomepage.Factory
  import Ecto.Query, only: [from: 2]

  setup do
    user = create(:user)
    team = create(:team)
    {:ok, _, socket} =
      socket("users_socket: #{user.id}", %{current_user: user})
      |> subscribe_and_join(TeamChatChannel, "team-chats:#{team.id}")

    {:ok, socket: socket}
  end

  test "new chat message replies with status ok", %{socket: socket} do
    assert count == 0
    ref = push socket, "message:add", %{"message" => "Hello!"}
    assert_reply ref, :ok
    assert count == 1
  end

  test "new chat message broadcasts to team-chats:<team_id>", %{socket: socket} do
    push socket, "message:add", %{"message" => "Hi"}
    assert_broadcast "message:added", %{"message" => "Hi"}
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
