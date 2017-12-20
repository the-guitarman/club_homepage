defmodule ClubHomepage.MatchCommitmentsChannelTest do
  use ClubHomepage.Web.ChannelCase

  alias ClubHomepage.Web.MatchCommitmentsChannel
  alias ClubHomepage.MatchCommitment

  import ClubHomepage.Factory

  setup do
    match = insert(:match)
    user = insert(:user)
    {:ok, _, socket} =
      socket("users_socket: #{user.id}", %{current_user: user})
      |> subscribe_and_join(MatchCommitmentsChannel, "match-commitments:#{match.id}")
    {:ok, socket: socket, current_user: user, match: match}
  end

  test "push participation:yes for non player", %{socket: socket, match: match} do
    user = insert(:user, roles: "member")
    attributes = %{:match_id => match.id, :user_id => user.id}

    refute Repo.get_by(MatchCommitment, Map.to_list(attributes))

    ref = push socket, "participation:yes", %{"user_id" => user.id}

    assert_reply ref, :error, ^attributes

    refute Repo.get_by(MatchCommitment, Map.to_list(attributes))
  end

  test "push participation:yes for a player", %{socket: socket, match: match} do
    user = insert(:user, roles: "member player")
    attributes = %{:match_id => match.id, :user_id => user.id}

    refute Repo.get_by(MatchCommitment, Map.to_list(attributes))

    ref = push socket, "participation:yes", %{"user_id" => user.id}

    assert_reply ref, :ok, ^attributes

    match_commitment = Repo.get_by(MatchCommitment, Map.to_list(attributes))
    assert match_commitment
    assert match_commitment.commitment == 1
  end

  test "push participation:no and update match commitment to no", %{socket: socket, match: match} do
    user = insert(:user)
    match_commitment = insert(:match_commitment, match_id: match.id, user_id: user.id, commitment: 1)

    assert Repo.get(MatchCommitment, match_commitment.id)

    ref = push socket, "participation:no", %{"user_id" => user.id}

    expected_payload = %{:match_id => match.id, :user_id => user.id}
    assert_reply ref, :ok, ^expected_payload

    match_commitment = Repo.get(MatchCommitment, match_commitment.id)
    assert match_commitment
    assert match_commitment.commitment == -1
  end

  test "push participation:dont-no and update match commitment to don't no", %{socket: socket, match: match} do
    user = insert(:user)
    match_commitment = insert(:match_commitment, match_id: match.id, user_id: user.id, commitment: 0)

    assert Repo.get(MatchCommitment, match_commitment.id)

    ref = push socket, "participation:dont-no", %{"user_id" => user.id}

    expected_payload = %{:match_id => match.id, :user_id => user.id}
    assert_reply ref, :ok, ^expected_payload

    match_commitment = Repo.get(MatchCommitment, match_commitment.id)
    assert match_commitment
    assert match_commitment.commitment == 0
  end
end
