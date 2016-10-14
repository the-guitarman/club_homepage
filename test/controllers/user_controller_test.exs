defmodule ClubHomepage.UserControllerTest do
  use ClubHomepage.ConnCase

  alias ClubHomepage.User

  import ClubHomepage.Factory

  @valid_attrs %{birthday: "17.04.1988", email: "mail@example.de", login: "my_login", name: "some name", password: "my name"}
  @invalid_attrs %{}
  @invalid_attrs2 %{email: "invalid"}

  setup context do
    conn = build_conn()
    role = context[:login]
    cond do
      role == true -> assign_current_user(conn, insert(:user, roles: "member administrator"))
      is_binary(role) -> assign_current_user(conn, insert(:user, roles: "member #{role}"))
      true -> {:ok, conn: conn}
    end
  end

  @tag login: false
  test "requires user authentication on all actions", %{conn: conn} do
    user = insert(:user)
    Enum.each([
      get(conn, managed_user_path(conn, :index)),
      get(conn, unregistered_user_path(conn, :new_unregistered)),
      post(conn, unregistered_user_path(conn, :create_unregistered), user: @valid_attrs),
      get(conn, managed_user_path(conn, :edit, user)),
      put(conn, managed_user_path(conn, :update, user), user: @valid_attrs)
    ], fn conn ->
      assert html_response(conn, 302)
      assert conn.halted
      assert redirected_to(conn) =~ "/"
    end)
  end

  @tag login: "administrator"
  test "an administrator can access the index action", %{conn: conn, current_user: _current_user} do
    conn = get conn, managed_user_path(conn, :index)
    assert html_response(conn, 200) =~ "All Club Members"
  end

  @tag login: "user-editor"
  test "an user-editor can access the index action", %{conn: conn, current_user: _current_user} do
    conn = get conn, managed_user_path(conn, :index)
    assert html_response(conn, 200) =~ "All Club Members"
  end

  @tag login: "match-editor news-editor player text-page-editor trainer"
  test "all other roles can not access the index action", %{conn: conn, current_user: _current_user} do
    conn = get conn, managed_user_path(conn, :index)
    assert html_response(conn, 302)
    assert conn.halted
    assert redirected_to(conn) =~ "/"
  end

  @tag login: true
  test "try to lists all entries on index with login", %{conn: conn, current_user: _current_user} do
    user = insert(:user)
    unregistered_user = insert(:unregistered_user)
    conn = get conn, managed_user_path(conn, :index)
    assert html_response(conn, 200) =~ "All Club Members"
    assert html_response(conn, 200) =~ "<td>#{user.email}</td>"
    assert html_response(conn, 200) =~ "<td>#{unregistered_user.email}</td>"
  end

  @tag login: true
  test "renders form for new unregistered users with current_user logged in", %{conn: conn, current_user: _current_user} do
    conn = get conn, unregistered_user_path(conn, :new_unregistered)
    assert html_response(conn, 200) =~ "<h2>Create Club Member</h2>"
  end

  @tag login: true
  test "tries to create unregistered user with current_user is logged in", %{conn: conn, current_user: _current_user} do
    conn = post conn, unregistered_user_path(conn, :create_unregistered), user: %{}
    refute html_response(conn, 200) =~ "Secret wird benötigt"
    refute html_response(conn, 200) =~ "Login can&#39;t be blank"
    assert html_response(conn, 200) =~ "name can&#39;t be blank"
    assert html_response(conn, 200) =~ "email can&#39;t be blank"
    refute html_response(conn, 200) =~ "birthday can&#39;t be blank"
  end

  @tag login: true
  test "create unregistered user with current_user is logged in", %{conn: conn, current_user: _current_user} do
    user_attributes = %{email: "total-new-email@example.com", name: "total-new-name"}
    conn = post conn, unregistered_user_path(conn, :create_unregistered), user: user_attributes

    assert redirected_to(conn) == unregistered_user_path(conn, :new_unregistered)
    unregistered_user = Repo.get_by(User, email: user_attributes.email)
    assert unregistered_user.name == user_attributes.name
    assert unregistered_user.active == false
  end

  @tag login: true
  test "renders form for new users without secret parameter", %{conn: conn, current_user: _current_user} do
    conn = get conn, user_path(conn, :new)
    assert html_response(conn, 200) =~ "Save"
  end

  @tag login: true
  test "renders form for new users with secret parameter", %{conn: conn, current_user: _current_user} do
    conn = get conn, user_path(conn, :new, secret: "sdkljsdflksdjfisd")
    assert html_response(conn, 200) =~ "Save"
  end

  @tag login: true
  test "creates resource and redirects when data is valid", %{conn: conn, current_user: _current_user} do
    conn = post conn, user_path(conn, :create), user: @valid_attrs
    assert html_response(conn, 200) =~ "Save"
    assert html_response(conn, 200) =~ "Secret can&#39;t be blank"

    secret = insert(:secret)
    new_valid_attrs = Map.put(@valid_attrs, :secret, secret.key)
    conn = post conn, user_path(conn, :create), user: new_valid_attrs

    assert redirected_to(conn) == page_path(conn, :index)
    user = Repo.get_by(User, login: @valid_attrs.login)
    assert user.active
    assert user.id == conn.assigns.current_user.id
  end

  @tag login: true
  test "does not create resource and renders errors when data is invalid", %{conn: conn, current_user: _current_user} do
    conn = post conn, user_path(conn, :create), user: @invalid_attrs
    assert html_response(conn, 200) =~ "Save"
    assert html_response(conn, 200) =~ "Secret can&#39;t be blank"
    assert html_response(conn, 200) =~ "login can&#39;t be blank"
    assert html_response(conn, 200) =~ "name can&#39;t be blank"
    assert html_response(conn, 200) =~ "email can&#39;t be blank"
    assert html_response(conn, 200) =~ "birthday can&#39;t be blank"
  end

  @tag login: true
  test "renders form for editing chosen resource", %{conn: conn} do
    user = insert(:user)
    conn = get conn, managed_user_path(conn, :edit, user)
    assert html_response(conn, 200) =~ "<h2>Edit Club Member</h2>"
  end

  @tag login: true
  test "updates chosen resource and redirects when data is valid", %{conn: conn} do
    user = insert(:user)
    conn = put conn, managed_user_path(conn, :update, user), user: @valid_attrs
    assert redirected_to(conn) == managed_user_path(conn, :index)
    assert Repo.get_by(User, email: @valid_attrs[:email])
  end

  @tag login: true
  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    user = insert(:user)
    conn = put conn, managed_user_path(conn, :update, user), user: @invalid_attrs2
    assert html_response(conn, 200) =~ "<h2>Edit Club Member</h2>"
  end

  # test "deletes chosen resource", %{conn: conn} do
  #   user = Repo.insert! %User{}
  #   conn = delete conn, user_path(conn, :delete, user)
  #   assert redirected_to(conn) == user_path(conn, :index)
  #   refute Repo.get(User, user.id)
  # end

  defp assign_current_user(conn, current_user) do
    conn = assign(conn, :current_user, current_user)
    {:ok, conn: conn, current_user: current_user}
  end
end
