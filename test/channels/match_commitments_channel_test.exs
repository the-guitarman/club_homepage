defmodule ClubHomepage.MatchCommitmentsChannelTest do
  use ClubHomepage.Web.ChannelCase

  alias ClubHomepage.Web.MatchCommitmentsChannel
  alias ClubHomepage.MatchCommitment

  import ClubHomepage.Factory

  setup do
    user = insert(:user, roles: "member player")
    {:ok, _, socket} =
      socket("user_socket: #{user.id}", %{current_user: user})
      |> subscribe_and_join(MatchCommitmentsChannel, "match-commitments:#{user.id}")
    {:ok, socket: socket, current_user: user}
  end

  test "push participation:yes for non player", %{socket: _socket, current_user: _current_user} do
    user = insert(:user, roles: "member")
    {:ok, _, socket} = 
      socket("user_socket: #{user.id}", %{current_user: user})
      |> subscribe_and_join(MatchCommitmentsChannel, "match-commitments:#{user.id}")

    match = insert(:match)
    attributes = %{user_id: user.id, match_id: match.id}

    refute Repo.get_by(MatchCommitment, Map.to_list(attributes))

    ref = push socket, "participation:yes", %{"match_id" => match.id}

    assert_reply ref, :error, ^attributes

    refute Repo.get_by(MatchCommitment, Map.to_list(attributes))

    leave_socket(socket)
  end

  test "push participation:yes for a player", %{socket: socket, current_user: current_user} do
    match = insert(:match)
    attributes = %{user_id: current_user.id, match_id: match.id}

    refute Repo.get_by(MatchCommitment, Map.to_list(attributes))

    ref = push socket, "participation:yes", %{"match_id" => match.id}

    assert_reply ref, :ok, ^attributes

    match_commitment = Repo.get_by(MatchCommitment, Map.to_list(attributes))
    assert match_commitment
    assert match_commitment.commitment == 1

    leave_socket(socket)
  end

  test "push participation:no and update user commitment to no", %{socket: socket, current_user: current_user} do
    match = insert(:match)
    match_commitment = insert(:match_commitment, user_id: current_user.id, match_id: match.id, commitment: 1)

    assert Repo.get(MatchCommitment, match_commitment.id)

    ref = push socket, "participation:no", %{"match_id" => match.id}

    expected_payload = %{user_id: current_user.id, match_id: match.id}
    assert_reply ref, :ok, ^expected_payload

    match_commitment = Repo.get(MatchCommitment, match_commitment.id)
    assert match_commitment
    assert match_commitment.commitment == -1

    leave_socket(socket)
  end

  test "push participation:dont-no and update user commitment to don't no", %{socket: socket, current_user: current_user} do
    match = insert(:match)
    match_commitment = insert(:match_commitment, user_id: current_user.id, match_id: match.id, commitment: 0)

    assert Repo.get(MatchCommitment, match_commitment.id)

    ref = push socket, "participation:dont-no", %{"match_id" => match.id}

    expected_payload = %{user_id: current_user.id, match_id: match.id}
    assert_reply ref, :ok, ^expected_payload

    match_commitment = Repo.get(MatchCommitment, match_commitment.id)
    assert match_commitment
    assert match_commitment.commitment == 0

    leave_socket(socket)
  end
end
