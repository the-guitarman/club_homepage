defmodule ClubHomepage.UserRoleTest do
  use ClubHomepage.ModelCase

  alias ClubHomepage.User
  alias ClubHomepage.Web.UserRole

  import ClubHomepage.Factory

  test "changeset with valid attributes" do
    user = insert(:user)
    changeset = User.changeset(user, %{roles: "member player"})
    {:ok, user} = Repo.update(changeset)
    assert UserRole.has_role?(user, "member")
    assert UserRole.has_role?(user, "player")
    refute UserRole.has_role?(user, "editor")
    assert UserRole.has_role?(user, ["editor", "player"])
    refute UserRole.has_role?(user, ["editor", "match-editor"])
  end

  test "defined roles" do
    defined_roles = UserRole.defined_roles_keys()
    assert Enum.member?(defined_roles, "member")
    assert Enum.member?(defined_roles, "administrator")
    assert Enum.member?(defined_roles, "match-editor")
    assert Enum.member?(defined_roles, "news-editor")
    assert Enum.member?(defined_roles, "player")
    assert Enum.member?(defined_roles, "text-page-editor")
    assert Enum.member?(defined_roles, "user-editor")
  end

  test "editable roles for nobody" do
    editable_roles = UserRole.editable_roles(nil)
    assert Enum.empty?(editable_roles)
  end

  test "editable roles for an administrator" do
    user = %User{roles: "member administrator"}
    editable_roles = UserRole.editable_roles(user)
    roles =
      UserRole.defined_roles_keys()
      |> Enum.filter(fn(role) -> not Enum.member?(["member"], role) end)
    assert Enum.count(editable_roles) == Enum.count(roles)
    for role <- roles do
      assert Enum.member?(editable_roles, role)
    end
  end

  test "editable roles for an user-editor" do
    user = %User{roles: "member user-editor"}
    editable_roles = UserRole.editable_roles(user)
    roles =
      UserRole.defined_roles_keys()
      |> Enum.filter(fn(role) -> not Enum.member?(["member", "administrator"], role) end)
    assert Enum.count(editable_roles) == Enum.count(roles)
    for role <- roles do
      assert Enum.member?(editable_roles, role)
    end
  end

  test "editable roles for all other" do
    user = %User{roles: "member match-editor news-editor player text-page-editor"}
    editable_roles = UserRole.editable_roles(user)
    assert Enum.empty?(editable_roles)
  end

  test "new user roles" do
    
  end

  test "checking roles" do
    
  end

  test "spliting roles" do
    roles = UserRole.split("member player")
    assert Enum.count(roles) == 2
    assert Enum.member?(roles, "member")
    assert Enum.member?(roles, "player")
  end
end
