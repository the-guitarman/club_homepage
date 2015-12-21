defmodule ClubHomepage.UserRoleTest do
  use ClubHomepage.ModelCase

  alias ClubHomepage.User
  alias ClubHomepage.UserRole

  import ClubHomepage.Factory

  test "changeset with valid attributes" do
    user = create(:user)
    changeset = User.changeset(user, %{roles: "member player"})
    {:ok, user} = Repo.update(changeset)
    assert UserRole.has_role?(user, "member")
    assert UserRole.has_role?(user, "player")
    refute UserRole.has_role?(user, "editor")
  end
end
