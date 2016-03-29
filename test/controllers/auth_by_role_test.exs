defmodule ClubHomepage.AuthByRoleTest do
  use ClubHomepage.ConnCase
  alias ClubHomepage.AuthByRole

  setup do
    conn =
      conn()
      |> bypass_through(ClubHomepage.Router, :browser)
      |> get("/")
    {:ok, %{conn: conn}}
  end

  test "is_administrator? halts when no current_user exists", %{conn: conn} do
    conn = AuthByRole.is_administrator?(conn, [])
    assert conn.halted
  end

  test "is_administrator? halts when current_user has no administrator role", %{conn: conn} do
    conn =
      conn
      |> assign(:current_user, %ClubHomepage.User{roles: "member player"})
      |> AuthByRole.is_administrator?([])
    assert conn.halted
  end

  test "is_administrator? continues when the current_user has the administrator role", %{conn: conn} do
    conn =
      conn
      |> assign(:current_user, %ClubHomepage.User{roles: "member administrator player"})
      |> AuthByRole.is_administrator?([])
    refute conn.halted
  end



  test "is_match_editor? halts when no current_user exists", %{conn: conn} do
    conn = AuthByRole.is_match_editor?(conn, [])
    assert conn.halted
  end

  test "is_match_editor? halts when current_user has no match-editor role", %{conn: conn} do
    conn =
      conn
      |> assign(:current_user, %ClubHomepage.User{roles: "member player"})
      |> AuthByRole.is_match_editor?([])
    assert conn.halted
  end

  test "is_match_editor? continues when the current_user has the match-editor role", %{conn: conn} do
    conn =
      conn
      |> assign(:current_user, %ClubHomepage.User{roles: "member match-editor player"})
      |> AuthByRole.is_match_editor?([])
    refute conn.halted
  end



  test "is_member? halts when no current_user exists", %{conn: conn} do
    conn = AuthByRole.is_member?(conn, [])
    assert conn.halted
  end

  test "is_member? halts when current_user has no member role", %{conn: conn} do
    conn =
      conn
    |> assign(:current_user, %ClubHomepage.User{roles: "player"})
    |> AuthByRole.is_member?([])
    assert conn.halted
  end

  test "is_member? continues when the current_user has the member role", %{conn: conn} do
    conn =
      conn
    |> assign(:current_user, %ClubHomepage.User{roles: "member player"})
    |> AuthByRole.is_member?([])
    refute conn.halted
  end



  test "is_news_editor? halts when no current_user exists", %{conn: conn} do
    conn = AuthByRole.is_news_editor?(conn, [])
    assert conn.halted
  end

  test "is_news_editor? halts when current_user has no news-editor role", %{conn: conn} do
    conn =
      conn
      |> assign(:current_user, %ClubHomepage.User{roles: "member player"})
      |> AuthByRole.is_news_editor?([])
    assert conn.halted
  end

  test "is_news_editor? continues when the current_user has the news-editor role", %{conn: conn} do
    conn =
      conn
      |> assign(:current_user, %ClubHomepage.User{roles: "member news-editor player"})
      |> AuthByRole.is_news_editor?([])
    refute conn.halted
  end



  test "is_player? halts when no current_user exists", %{conn: conn} do
    conn = AuthByRole.is_player?(conn, [])
    assert conn.halted
  end

  test "is_player? halts when current_user has no player role", %{conn: conn} do
    conn =
      conn
    |> assign(:current_user, %ClubHomepage.User{roles: "member"})
    |> AuthByRole.is_player?([])
    assert conn.halted
  end

  test "is_player? continues when the current_user has the player role", %{conn: conn} do
    conn =
      conn
    |> assign(:current_user, %ClubHomepage.User{roles: "member player"})
    |> AuthByRole.is_player?([])
    refute conn.halted
  end



  test "is_text_page_editor? halts when no current_user exists", %{conn: conn} do
    conn = AuthByRole.is_text_page_editor?(conn, [])
    assert conn.halted
  end

  test "is_text_page_editor? halts when current_user has no text-page-editor role", %{conn: conn} do
    conn =
      conn
    |> assign(:current_user, %ClubHomepage.User{roles: "member player"})
    |> AuthByRole.is_text_page_editor?([])
    assert conn.halted
  end

  test "is_text_page_editor? continues when the current_user has the text-page-editor role", %{conn: conn} do
    conn =
      conn
    |> assign(:current_user, %ClubHomepage.User{roles: "member text-page-editor player"})
    |> AuthByRole.is_text_page_editor?([])
    refute conn.halted
  end



  test "is_trainer? halts when no current_user exists", %{conn: conn} do
    conn = AuthByRole.is_trainer?(conn, [])
    assert conn.halted
  end

  test "is_trainer? halts when current_user has no trainer role", %{conn: conn} do
    conn =
      conn
    |> assign(:current_user, %ClubHomepage.User{roles: "member player"})
    |> AuthByRole.is_trainer?([])
    assert conn.halted
  end

  test "is_trainer? continues when the current_user has the trainer role", %{conn: conn} do
    conn =
      conn
    |> assign(:current_user, %ClubHomepage.User{roles: "member trainer player"})
    |> AuthByRole.is_trainer?([])
    refute conn.halted
  end
end
