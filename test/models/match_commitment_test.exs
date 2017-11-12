defmodule ClubHomepage.MatchCommitmentTest do
  use ClubHomepage.ModelCase

  # alias Ecto.Changeset
  # alias ClubHomepage.Match
  alias ClubHomepage.MatchCommitment
  # alias ClubHomepage.User

  import ClubHomepage.Factory

  @valid_attrs %{match_id: 1, user_id: 1, commitment: 0}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    match = insert(:match)
    user = insert(:user)
    valid_attrs = %{@valid_attrs | match_id: match.id, user_id: user.id}
    changeset = MatchCommitment.changeset(%MatchCommitment{}, valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = MatchCommitment.changeset(%MatchCommitment{}, @invalid_attrs)
    refute changeset.valid?
  end
end
