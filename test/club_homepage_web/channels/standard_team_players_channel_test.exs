defmodule ClubHomepage.StandardTeamPlayersChannelTest do
  use ClubHomepageWeb.ChannelCase

  alias ClubHomepageWeb.StandardTeamPlayersChannel
  alias ClubHomepage.StandardTeamPlayer

  import ClubHomepage.Factory

  setup do
    user = insert(:user)
    team = insert(:team)
    {:ok, _, socket} =
      socket(ClubHomepageWeb.UserSocket, "users_socket: #{user.id}", %{current_user: user})
      |> subscribe_and_join(StandardTeamPlayersChannel, "standard-team-players:#{team.id}")
    {:ok, socket: socket, current_user: user, team: team}
  end

  test "push player:add_or_update for non player", %{socket: socket, team: team} do
    user = insert(:user, roles: "member")
    attributes = %{:team_id => team.id, :user_id => user.id}

    refute Repo.get_by(StandardTeamPlayer, Map.to_list(attributes))

    ref = push socket, "player:add_or_update", %{"user_id" => user.id, "standard_shirt_number" => ""}

    #assert_push "player:add", ^attributes
    #assert_broadcast "player:added", ^attributes
    attrs =
      attributes
      |> Map.put(:standard_shirt_number, "")
      |> Map.put(:errors, %{user_id: "The User needs to be a Player."})
    assert_reply ref, :error, ^attrs

    refute Repo.get_by(StandardTeamPlayer, Map.to_list(attributes))
    #leave_socket(socket)
  end

  test "push player:add_or_update for a player", %{socket: socket, team: team} do
    user = insert(:user, roles: "member player")
    attributes = %{:team_id => team.id, :user_id => user.id}

    refute Repo.get_by(StandardTeamPlayer, Map.to_list(attributes))

    ref = push socket, "player:add_or_update", %{"user_id" => user.id, "standard_shirt_number" => ""}

    #assert_push "player:add", ^attributes
    attrs = Map.put(attributes, :standard_shirt_number, nil)
    assert_broadcast "player:added_or_updated", ^attrs
    assert_reply ref, :ok, ^attrs

    assert Repo.get_by(StandardTeamPlayer, Map.to_list(attributes))
    #leave_socket(socket)
  end

  test "push player:remove", %{socket: socket, team: team} do
    user = insert(:user)
    standard_team_player = insert(:standard_team_player, team_id: team.id, user_id: user.id)

    assert Repo.get(StandardTeamPlayer, standard_team_player.id)

    ref = push socket, "player:remove", %{"user_id" => user.id, "standard_shirt_number" => ""}

    expected_payload = %{:team_id => team.id, :user_id => user.id, :standard_shirt_number => ""}
    #assert_push "player:remove", ^expected_payload
    assert_broadcast "player:removed", ^expected_payload
    assert_reply ref, :ok, ^expected_payload

    refute Repo.get(StandardTeamPlayer, standard_team_player.id)
    #leave_socket(socket)
  end
end
