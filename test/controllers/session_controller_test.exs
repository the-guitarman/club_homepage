defmodule ClubHomepage.SessionControllerTest do
  use ClubHomepage.ConnCase

  #alias ClubHomepage.User

  import ClubHomepage.Factory

  setup do
    conn = conn()
    {:ok, conn: conn}
  end

  test "inactive user can not be logged in", %{conn: conn} do
    user = create(:user)
    user = Ecto.Changeset.change(user, active: false)
    {:ok, user} = Repo.update(user)

    conn = post conn, session_path(conn, :create), session: %{login: user.email, password: "my password", redirect: "/"}
    assert html_response(conn, 200) =~ "Your account is inactive."
  end

  test "active user can be logged in", %{conn: conn} do
    user = create(:user)
    user = Ecto.Changeset.change(user, active: true)
    {:ok, user} = Repo.update(user)

    conn = post conn, session_path(conn, :create), session: %{login: user.email, password: "my password", redirect: "/manage/teams"}
    assert redirected_to(conn) =~ "/manage/teams"
    assert html_response(conn, 302)
  end
end
