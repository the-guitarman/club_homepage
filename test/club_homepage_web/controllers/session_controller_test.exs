defmodule ClubHomepage.SessionControllerTest do
  use ClubHomepage.Web.ConnCase

  #alias ClubHomepage.User

  import ClubHomepage.Factory

  setup context do
    conn = build_conn()
    if context[:login] do
      current_user = 
      if context[:user_roles] do
        insert(:user, roles: context[:user_roles])
      else
        insert(:user)
      end
      conn = assign(conn, :current_user, current_user)
      {:ok, conn: conn, current_user: current_user}
    else
      {:ok, conn: conn}
    end
  end

  @tag login: false
  test "requires user authentication on all actions", %{conn: conn} do
    Enum.each([
      delete(conn, session_path(conn, :delete))
    ], fn conn ->
      assert html_response(conn, 302)
      assert redirected_to(conn) =~ "/"
      assert conn.halted
    end)
  end

  @tag login: true
  test "requires no user authentication on all actions", %{conn: conn, current_user: _current_user} do
    user = insert(:user)
    Enum.each([
      get(conn, session_path(conn, :new)),
      post(conn, session_path(conn, :create), session: %{login: user.email, password: "my password"}),
    ], fn conn ->
      assert html_response(conn, 302)
      assert conn.halted
      assert redirected_to(conn) =~ "/"
    end)
  end

  @tag login: false
  test "inactive user can not be logged in", %{conn: conn} do
    user = insert(:user)
    user = Ecto.Changeset.change(user, active: false)
    {:ok, user} = Repo.update(user)

    conn = post conn, session_path(conn, :create), session: %{login: user.email, password: "my password", redirect: "/"}
    assert html_response(conn, 200) =~ "Your account is inactive."
  end

  @tag login: false
  test "active user can be logged in", %{conn: conn} do
    user = insert(:user)
    user = Ecto.Changeset.change(user, active: true)
    {:ok, user} = Repo.update(user)

    conn = post conn, session_path(conn, :create), session: %{login: user.email, password: "my password", redirect: "/manage/teams"}
    assert redirected_to(conn) =~ "/manage/teams"
    assert html_response(conn, 302)
  end

  @tag login: true
  test "logout the current user", %{conn: conn} do
    conn = delete conn, session_path(conn, :delete)
    assert flash_messages_contain?(conn, "You are logged out now.")
    assert redirected_to(conn) =~ "/"
    assert html_response(conn, 302)
  end
end
