defmodule ClubHomepage.MatchCommitmentTest do
  use ClubHomepage.ModelCase

  alias ClubHomepage.MatchCommitment

  import ClubHomepage.Factory

  @invalid_attrs %{}

  test "changeset with invalid attributes" do
    changeset = MatchCommitment.changeset(%MatchCommitment{}, @invalid_attrs)
    refute changeset.valid?
  end

  test "user needs to be a player" do
    match = insert(:match)
    user = insert(:user, roles: "member")

    changeset = MatchCommitment.changeset(%MatchCommitment{}, %{match_id: match.id, user_id: user.id})

    refute changeset.valid?
  end

  test "user is a player and is unique" do
    match = insert(:match)
    user = insert(:user, roles: "member player")

    changeset = MatchCommitment.changeset(%MatchCommitment{}, %{match_id: match.id, user_id: user.id, commitment: -1})

    assert changeset.valid?

    {:ok, match_commitment} = Repo.insert(changeset)
    assert match_commitment.match_id == match.id
    assert match_commitment.user_id == user.id
    assert match_commitment.commitment == -1


    {:error, changeset} = Repo.insert(changeset)
    assert changeset.errors[:user_id] == {"has already been taken", []}
  end
end
