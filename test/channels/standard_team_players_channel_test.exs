defmodule ClubHomepage.StandardTeamPlayersChannelTest do
  use ClubHomepage.Web.ChannelCase

  alias ClubHomepage.Web.StandardTeamPlayersChannel
  alias ClubHomepage.StandardTeamPlayer

  import ClubHomepage.Factory

  setup do
    user = insert(:user)
    team = insert(:team)
    {:ok, _, socket} =
      socket("users_socket: #{user.id}", %{current_user: user})
      |> subscribe_and_join(StandardTeamPlayersChannel, "standard-team-players:#{team.id}")
    {:ok, socket: socket, current_user: user, team: team}
  end

  test "push player:add for non player", %{socket: socket, team: team} do
    user = insert(:user, roles: "member")
    attributes = %{:team_id => team.id, :user_id => user.id}

    refute Repo.get_by(StandardTeamPlayer, Map.to_list(attributes))

    ref = push socket, "player:add", %{"user_id" => user.id}

    #assert_push "player:add", ^attributes
    #assert_broadcast "player:added", ^attributes
    assert_reply ref, :error, ^attributes

    refute Repo.get_by(StandardTeamPlayer, Map.to_list(attributes))
  end

  test "push player:add for a player", %{socket: socket, team: team} do
    user = insert(:user, roles: "member player")
    attributes = %{:team_id => team.id, :user_id => user.id}

    refute Repo.get_by(StandardTeamPlayer, Map.to_list(attributes))

    ref = push socket, "player:add", %{"user_id" => user.id}

    #assert_push "player:add", ^attributes
    assert_broadcast "player:added", ^attributes
    assert_reply ref, :ok, ^attributes

    assert Repo.get_by(StandardTeamPlayer, Map.to_list(attributes))
  end

  test "push player:remove", %{socket: socket, team: team} do
    user = insert(:user)
    standard_team_player = insert(:standard_team_player, team_id: team.id, user_id: user.id)

    assert Repo.get(StandardTeamPlayer, standard_team_player.id)

    ref = push socket, "player:remove", %{"user_id" => user.id}

    expected_payload = %{:team_id => team.id, :user_id => user.id}
    #assert_push "player:remove", ^expected_payload
    assert_broadcast "player:removed", ^expected_payload
    assert_reply ref, :ok, ^expected_payload

    refute Repo.get(StandardTeamPlayer, standard_team_player.id)
  end
end
