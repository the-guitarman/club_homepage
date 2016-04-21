defmodule ClubHomepage.TeamControllerTest do
  use ClubHomepage.ConnCase

  alias ClubHomepage.Extension.CommonSeason
  alias ClubHomepage.Team

  import ClubHomepage.Factory

  competition = create(:competition)
  @valid_attrs %{competition_id: competition.id, name: "This is my    team without ß in the name."}
  @invalid_attrs %{name: ""}

  setup context do
    conn = conn()
    competition   = create(:competition)
    valid_attrs = %{@valid_attrs | competition_id: competition.id}
    if context[:login] do
      current_user = create(:user)
      conn = assign(conn, :current_user, current_user)
      {:ok, conn: conn, current_user: current_user, valid_attrs: valid_attrs}
    else
      {:ok, conn: conn, valid_attrs: valid_attrs}
    end
  end

  @tag login: false
  test "requires user authentication on all actions", %{conn: conn, valid_attrs: valid_attrs} do
    team = create(:team)
    Enum.each([
      get(conn, team_path(conn, :index)),
      get(conn, team_path(conn, :new)),
      post(conn, team_path(conn, :create), team: valid_attrs),
      post(conn, team_path(conn, :create), team: @invalid_attrs),
      get(conn, team_path(conn, :edit, team)),
      put(conn, team_path(conn, :update, team), team: valid_attrs),
      put(conn, team_path(conn, :update, team), team: @invalid_attrs),
      delete(conn, team_path(conn, :delete, team))
    ], fn conn ->
      assert html_response(conn, 302)
      assert conn.halted
      assert redirected_to(conn) =~ "/"
    end)
  end

  @tag login: true
  test "try to lists all entries on index", %{conn: conn, current_user: _current_user, valid_attrs: _valid_attrs} do
    conn = get conn, team_path(conn, :index)
    assert html_response(conn, 200) =~ "All Teams"
  end

  @tag login: true
  test "renders form for new resources", %{conn: conn, current_user: _current_user, valid_attrs: _valid_attrs} do
    conn = get conn, team_path(conn, :new)
    assert html_response(conn, 200) =~ "Create Team"
  end

  @tag login: true
  test "creates resource and redirects when data is valid", %{conn: conn, current_user: _current_user, valid_attrs: _valid_attrs} do
    conn = post conn, team_path(conn, :create), team: @valid_attrs
    assert redirected_to(conn) == team_path(conn, :index) <> "#team-1"
    assert Repo.get_by(Team, @valid_attrs)
  end

  @tag login: true
  test "does not create resource and renders errors when data is invalid", %{conn: conn, current_user: _current_user, valid_attrs: _valid_attrs} do
    conn = post conn, team_path(conn, :create), team: @invalid_attrs
    assert html_response(conn, 200) =~ "Create Team"
  end

  @tag login: false 
  test "shows team page", %{conn: conn} do
    team = create(:team)
    season = create(:season, name: CommonSeason.current_season_name)
    conn = get conn, team_page_path(conn, :show, team.slug)
    assert redirected_to(conn) == team_page_with_season_path(conn, :show, team.slug, season.name)
  end

  @tag login: false
  test "shows team with season page", %{conn: conn} do
    team = create(:team)
    season = create(:season)
    conn = get conn, team_page_with_season_path(conn, :show, team.slug, season.name)
    assert html_response(conn, 200) =~ "<h1>#{team.name}</h1>"
  end

  @tag login: false
  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_raise Ecto.NoResultsError, fn ->
      get conn, team_page_path(conn, :show, "unknown-team-slug")
    end
  end

  @tag login: true
  test "renders form for editing chosen resource", %{conn: conn, current_user: _current_user, valid_attrs: _valid_attrs} do
    team = create(:team)
    conn = get conn, team_path(conn, :edit, team)
    assert html_response(conn, 200) =~ "Edit Team"
  end

  @tag login: true
  test "updates chosen resource and redirects when data is valid", %{conn: conn, current_user: _current_user, valid_attrs: _valid_attrs} do
    team = create(:team)
    conn = put conn, team_path(conn, :update, team), team: @valid_attrs
    assert redirected_to(conn) == team_path(conn, :index) <> "#team-#{team.id}"
    assert Repo.get_by(Team, @valid_attrs)
  end

  @tag login: true
  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn, current_user: _current_user, valid_attrs: _valid_attrs} do
    team = create(:team)
    conn = put conn, team_path(conn, :update, team), team: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit Team"
  end

  @tag login: true
  test "try to delete chosen resource", %{conn: conn, current_user: _current_user, valid_attrs: _valid_attrs} do
    team = create(:team)
    conn = delete conn, team_path(conn, :delete, team)
    assert redirected_to(conn) == team_path(conn, :index)
    refute Repo.get(Team, team.id)
  end
end
