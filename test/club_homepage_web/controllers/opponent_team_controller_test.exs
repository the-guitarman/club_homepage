defmodule ClubHomepage.OpponentTeamControllerTest do
  use ClubHomepage.Web.ConnCase

  alias ClubHomepage.OpponentTeam

  import ClubHomepage.Factory

  @valid_attrs %{name: "some content"}
  @invalid_attrs %{}

  setup context do
    conn = build_conn()
    if context[:login] do
      current_user = insert(:user)
      conn = assign(conn, :current_user, current_user)
      {:ok, conn: conn, current_user: current_user}
    else
      {:ok, conn: conn}
    end
  end

  @tag login: false
  test "requires user authentication on all actions", %{conn: conn} do
    opponent_team = insert(:opponent_team)
    Enum.each([
      get(conn, opponent_team_path(conn, :index)),
      get(conn, opponent_team_path(conn, :new)),
      post(conn, opponent_team_path(conn, :create), opponent_team: @valid_attrs),
      get(conn, opponent_team_path(conn, :edit, opponent_team)),
      put(conn, opponent_team_path(conn, :update, opponent_team), opponent_team: @valid_attrs),
      put(conn, opponent_team_path(conn, :update, opponent_team), opponent_team: @invalid_attrs),
      delete(conn, opponent_team_path(conn, :delete, opponent_team))
    ], fn conn ->
      assert html_response(conn, 302)
      assert conn.halted
      assert redirected_to(conn) =~ "/"
    end)
  end

  @tag login: true
  test "lists all entries on index", %{conn: conn} do
    conn = get conn, opponent_team_path(conn, :index)
    assert html_response(conn, 200) =~ "All Opponent Teams"
  end

  @tag login: true
  test "renders form for new resources", %{conn: conn} do
    conn = get conn, opponent_team_path(conn, :new)
    assert html_response(conn, 200) =~ "Create Opponent Team"
  end

  @tag login: true
  test "creates resource and redirects when data is valid", %{conn: conn} do
    conn = post conn, opponent_team_path(conn, :create), opponent_team: @valid_attrs
    assert redirected_to(conn) == opponent_team_path(conn, :index) <> "#opponent-team-#{get_highest_id(OpponentTeam)}"
    assert Repo.get_by(OpponentTeam, @valid_attrs)
  end

  @tag login: true
  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, opponent_team_path(conn, :create), opponent_team: @invalid_attrs
    assert html_response(conn, 200) =~ "Create Opponent Team"
  end

  @tag login: true
  test "renders form for editing chosen resource", %{conn: conn} do
    opponent_team = Repo.insert! %OpponentTeam{}
    conn = get conn, opponent_team_path(conn, :edit, opponent_team)
    assert html_response(conn, 200) =~ "Edit Opponent Team"
  end

  @tag login: true
  test "updates chosen resource and redirects when data is valid", %{conn: conn} do
    opponent_team = Repo.insert! %OpponentTeam{}
    conn = put conn, opponent_team_path(conn, :update, opponent_team), opponent_team: @valid_attrs
    assert redirected_to(conn) == opponent_team_path(conn, :index) <> "#opponent-team-#{opponent_team.id}"
    assert Repo.get_by(OpponentTeam, @valid_attrs)
  end

  @tag login: true
  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    opponent_team = Repo.insert! %OpponentTeam{}
    conn = put conn, opponent_team_path(conn, :update, opponent_team), opponent_team: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit Opponent Team"
  end

  @tag login: true
  test "deletes chosen resource", %{conn: conn} do
    opponent_team = Repo.insert! %OpponentTeam{}
    conn = delete conn, opponent_team_path(conn, :delete, opponent_team)
    assert redirected_to(conn) == opponent_team_path(conn, :index)
    refute Repo.get(OpponentTeam, opponent_team.id)
  end
end
