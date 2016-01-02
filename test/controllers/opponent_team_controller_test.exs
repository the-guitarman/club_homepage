defmodule ClubHomepage.OpponentTeamControllerTest do
  use ClubHomepage.ConnCase

  alias ClubHomepage.OpponentTeam
  @valid_attrs %{name: "some content"}
  @invalid_attrs %{}

  setup do
    conn = conn()
    {:ok, conn: conn}
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, opponent_team_path(conn, :index)
    assert html_response(conn, 200) =~ "Listing opponent teams"
  end

  test "renders form for new resources", %{conn: conn} do
    conn = get conn, opponent_team_path(conn, :new)
    assert html_response(conn, 200) =~ "New opponent team"
  end

  test "creates resource and redirects when data is valid", %{conn: conn} do
    conn = post conn, opponent_team_path(conn, :create), opponent_team: @valid_attrs
    assert redirected_to(conn) == opponent_team_path(conn, :index)
    assert Repo.get_by(OpponentTeam, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, opponent_team_path(conn, :create), opponent_team: @invalid_attrs
    assert html_response(conn, 200) =~ "New opponent team"
  end

  test "shows chosen resource", %{conn: conn} do
    opponent_team = Repo.insert! %OpponentTeam{}
    conn = get conn, opponent_team_path(conn, :show, opponent_team)
    assert html_response(conn, 200) =~ "Show opponent team"
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_raise Ecto.NoResultsError, fn ->
      get conn, opponent_team_path(conn, :show, -1)
    end
  end

  test "renders form for editing chosen resource", %{conn: conn} do
    opponent_team = Repo.insert! %OpponentTeam{}
    conn = get conn, opponent_team_path(conn, :edit, opponent_team)
    assert html_response(conn, 200) =~ "Edit opponent team"
  end

  test "updates chosen resource and redirects when data is valid", %{conn: conn} do
    opponent_team = Repo.insert! %OpponentTeam{}
    conn = put conn, opponent_team_path(conn, :update, opponent_team), opponent_team: @valid_attrs
    assert redirected_to(conn) == opponent_team_path(conn, :show, opponent_team)
    assert Repo.get_by(OpponentTeam, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    opponent_team = Repo.insert! %OpponentTeam{}
    conn = put conn, opponent_team_path(conn, :update, opponent_team), opponent_team: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit opponent team"
  end

  test "deletes chosen resource", %{conn: conn} do
    opponent_team = Repo.insert! %OpponentTeam{}
    conn = delete conn, opponent_team_path(conn, :delete, opponent_team)
    assert redirected_to(conn) == opponent_team_path(conn, :index)
    refute Repo.get(OpponentTeam, opponent_team.id)
  end
end
