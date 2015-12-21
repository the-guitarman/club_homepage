defmodule ClubHomepage.TeamControllerTest do
  use ClubHomepage.ConnCase

  alias ClubHomepage.Team

  import ClubHomepage.Factory

  @valid_attrs %{name: "This is my    team without ß in the name."}
  @invalid_attrs %{name: ""}

  setup do
    conn = conn()
    {:ok, conn: conn}
  end

  test "try to lists all entries on index without login", %{conn: conn} do
    conn = get conn, team_path(conn, :index)
    assert redirected_to(conn) =~ "/"
  end

  test "try to lists all entries on index with login", %{conn: conn} do
    conn = login(conn)
    conn = get conn, team_path(conn, :index)
    assert html_response(conn, 200) =~ "Alle Mannschaften"
  end

  test "renders form for new resources without login", %{conn: conn} do
    conn = get conn, team_path(conn, :new)
    assert redirected_to(conn) =~ "/"
  end

  test "renders form for new resources with login", %{conn: conn} do
    conn = login(conn)
    conn = get conn, team_path(conn, :new)
    assert html_response(conn, 200) =~ "Neue Mannschaft anlegen"
  end

  test "creates resource and redirects when data is valid without login", %{conn: conn} do
    conn = post conn, team_path(conn, :create), team: @valid_attrs
    assert redirected_to(conn) =~ "/"
  end

  test "creates resource and redirects when data is valid with login", %{conn: conn} do
    conn = login(conn)
    conn = post conn, team_path(conn, :create), team: @valid_attrs
    assert redirected_to(conn) == team_path(conn, :index)
    assert Repo.get_by(Team, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid without login", %{conn: conn} do
    conn = post conn, team_path(conn, :create), team: @invalid_attrs
    assert redirected_to(conn) =~ "/"
  end

  test "does not create resource and renders errors when data is invalid with login", %{conn: conn} do
    conn = login(conn)
    conn = post conn, team_path(conn, :create), team: @invalid_attrs
    assert html_response(conn, 200) =~ "Neue Mannschaft anlegen"
  end

  test "shows chosen resource without login", %{conn: conn} do
    team = create(:team)
    conn = get conn, team_path(conn, :show, team.rewrite)
    assert html_response(conn, 200) =~ "Show team"
  end

  test "shows chosen resource with login", %{conn: conn} do
    conn = login(conn)
    team = create(:team)
    conn = get conn, team_path(conn, :show, team.rewrite)
    assert html_response(conn, 200) =~ "Show team"
  end

  test "renders page not found when id is nonexistent without login", %{conn: conn} do
    assert_raise Ecto.NoResultsError, fn ->
      get conn, team_path(conn, :show, "unknown-permalink")
    end
  end

  test "renders page not found when id is nonexistent with login", %{conn: conn} do
    conn = login(conn)
    assert_raise Ecto.NoResultsError, fn ->
      get conn, team_path(conn, :show, "unknown-permalink")
    end
  end

  test "renders form for editing chosen resource without login", %{conn: conn} do
    team = create(:team)
    conn = get conn, team_path(conn, :edit, team)
    assert redirected_to(conn) == "/"
  end

  test "renders form for editing chosen resource with login", %{conn: conn} do
    conn = login(conn)
    team = create(:team)
    conn = get conn, team_path(conn, :edit, team)
    assert html_response(conn, 200) =~ "Edit team"
  end

  test "updates chosen resource and redirects when data is valid without login", %{conn: conn} do
    team = create(:team)
    conn = put conn, team_path(conn, :update, team), team: @valid_attrs
    assert redirected_to(conn) == "/"
  end

  test "updates chosen resource and redirects when data is valid with login", %{conn: conn} do
    conn = login(conn)
    team = create(:team)
    conn = put conn, team_path(conn, :update, team), team: @valid_attrs
    assert redirected_to(conn) == team_path(conn, :show, team)
    assert Repo.get_by(Team, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid without login", %{conn: conn} do
    team = create(:team)
    conn = put conn, team_path(conn, :update, team), team: @invalid_attrs
    assert redirected_to(conn) == "/"
  end

  test "does not update chosen resource and renders errors when data is invalid with login", %{conn: conn} do
    conn = login(conn)
    team = create(:team)
    conn = put conn, team_path(conn, :update, team), team: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit team"
  end

  test "try to delete chosen resource without login", %{conn: conn} do
    team = create(:team)
    conn = delete conn, team_path(conn, :delete, team)
    assert redirected_to(conn) == "/"
  end

  test "try to delete chosen resource with login", %{conn: conn} do
    conn = login(conn)
    team = create(:team)
    conn = delete conn, team_path(conn, :delete, team)
    assert redirected_to(conn) == team_path(conn, :index)
    refute Repo.get(Team, team.id)
  end

  defp login(conn) do
    user = create(:user)
    assign(conn, :current_user, user)
  end
end
