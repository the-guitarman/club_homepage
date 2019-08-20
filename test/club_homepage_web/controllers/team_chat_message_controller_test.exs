defmodule ClubHomepage.TeamChatMessageControllerTest do
  use ClubHomepage.Web.ConnCase

  alias ClubHomepage.TeamChatMessage

  import ClubHomepage.Factory

  @valid_attrs %{team_id: 0, user_id: 0, message: "Hi all!"}
  #@invalid_attrs %{}

  setup context do
    conn = build_conn()
    team = insert(:team)
    user = insert(:user)
    valid_attrs = %{@valid_attrs | team_id: team.id, user_id: user.id}
    if context[:login] do
      current_user = 
        if context[:user_roles] do
          insert(:user, roles: context[:user_roles])
        else
          insert(:user)
        end
      conn = assign(conn, :current_user, current_user)
      {:ok, conn: conn, current_user: current_user, valid_attrs: valid_attrs}
    else
      {:ok, conn: conn, valid_attrs: valid_attrs}
    end
  end

  @tag login: false
  test "requires user authentication on all actions", %{conn: conn, valid_attrs: _valid_attrs} do
    team_chat_message = insert(:team_chat_message)
    Enum.each([
      get(conn, team_chat_message_path(conn, :index)),
      delete(conn, team_chat_message_path(conn, :delete, team_chat_message))
    ], fn conn ->
      assert html_response(conn, 302)
      assert conn.halted
      assert redirected_to(conn) =~ "/"
    end)
  end

  @tag login: true
  test "lists all entries on index", %{conn: conn, current_user: _current_user, valid_attrs: _valid_attrs} do
    conn = get conn, team_chat_message_path(conn, :index)
    assert html_response(conn, 200) =~ "All Chat Messages"
  end

  @tag login: true
  test "deletes chosen resource", %{conn: conn, current_user: _current_user, valid_attrs: _valid_attrs} do
    team_chat_message = insert(:team_chat_message)
    conn = delete conn, team_chat_message_path(conn, :delete, team_chat_message)
    assert redirected_to(conn) == team_chat_message_path(conn, :index)
    refute Repo.get(TeamChatMessage, team_chat_message.id)
  end
end
