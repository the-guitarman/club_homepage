defmodule ClubHomepage.TeamControllerTest do
  use ClubHomepageWeb.ConnCase

  alias ClubHomepage.Extension.CommonSeason
  alias ClubHomepage.Team

  import ClubHomepage.Factory

  competition = insert(:competition)
  @valid_attrs %{competition_id: competition.id, name: "This is my    team without ß in the name."}
  @invalid_attrs %{name: ""}

  setup_all do
    uploads_path = Application.get_env(:club_homepage, :uploads)[:path]
    File.mkdir_p(uploads_path)

    on_exit fn ->
      File.rm_rf(uploads_path)
    end
  end

  setup context do
    conn = build_conn()
    competition   = insert(:competition)
    valid_attrs = %{@valid_attrs | competition_id: competition.id}
    if context[:login] do
      current_user = insert(:user)
      conn = assign(conn, :current_user, current_user)
      {:ok, conn: conn, current_user: current_user, valid_attrs: valid_attrs}
    else
      {:ok, conn: conn, valid_attrs: valid_attrs}
    end
  end

  @tag login: false
  test "requires user authentication on all actions", %{conn: conn, valid_attrs: valid_attrs} do
    team = insert(:team)
    Enum.each([
      get(conn, team_path(conn, :index)),
      get(conn, team_path(conn, :new)),
      post(conn, team_path(conn, :create), team: valid_attrs),
      post(conn, team_path(conn, :create), team: @invalid_attrs),
      get(conn, team_path(conn, :edit, team)),
      put(conn, team_path(conn, :update, team), team: valid_attrs),
      put(conn, team_path(conn, :update, team), team: @invalid_attrs),
      delete(conn, team_path(conn, :delete, team)),
      get(conn, team_chat_page_path(conn, :show_chat, team))
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
    assert redirected_to(conn) == team_path(conn, :index) <> "#team-#{get_highest_id(Team)}"
    assert Repo.get_by(Team, @valid_attrs)
  end

  @tag login: true
  test "does not create resource and renders errors when data is invalid", %{conn: conn, current_user: _current_user, valid_attrs: _valid_attrs} do
    conn = post conn, team_path(conn, :create), team: @invalid_attrs
    assert html_response(conn, 200) =~ "Create Team"
  end

  @tag login: false 
  test "shows team page", %{conn: conn} do
    team = insert(:team)
    season = insert(:season, name: CommonSeason.current_season_name)
    conn = get conn, team_page_path(conn, :show, team.slug)
    assert redirected_to(conn) == team_page_with_season_path(conn, :show, team.slug, season.name)
  end

  @tag login: false
  test "shows team with season page", %{conn: conn} do
    team = insert(:team, fussball_de_team_rewrite: "abc", fussball_de_team_id: "123", fussball_de_show_current_table: true)
    season = insert(:season)
    conn = get conn, team_page_with_season_path(conn, :show, team.slug, season.name)
    assert html_response(conn, 200) =~ "<h1>#{team.name}<br />Matches</h1>"
    assert html_response(conn, 200) =~ "row css-current-team-table"
  end

  @tag login: false
  test "shows team with season page for bot or search engine without current table",  %{conn: conn} do
    team = insert(:team, fussball_de_team_rewrite: "abc", fussball_de_team_id: "123", fussball_de_show_current_table: true)
    season = insert(:season)
    conn =
      conn
      |> put_req_header("user-agent", "googlebot")
    conn = get(conn, team_page_with_season_path(conn, :show, team.slug, season.name))
    assert html_response(conn, 200) =~ "<h1>#{team.name}<br />Matches</h1>"
    refute html_response(conn, 200) =~ "row css-current-team-table"
  end

  @tag login: false
  test "shows team images page", %{conn: conn} do
    team_image = insert(:team_image)
    team = Repo.get!(Team, team_image.team_id)
    conn = get conn, team_images_page_path(conn, :show_images, team.slug)
    assert html_response(conn, 200) =~ "<h1>#{team.name}<br />Team Images</h1>"
  end

  @tag login: true
  test "shows team chat page", %{conn: conn, current_user: _current_user} do
    team = insert(:team)
    conn = get conn, team_chat_page_path(conn, :show_chat, team)
    assert html_response(conn, 200) =~ "<h1>#{team.name}<br />Team Chat</h1>"
    assert html_response(conn, 200) =~ "<input type=\"hidden\" id=\"team-id\" value=\"#{team.id}\" />"
    #assert html_response(conn, 200) =~ "<h1>#{team.name}<br />Team Chat</h1>"
  end

  @tag login: false
  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_raise Ecto.NoResultsError, fn ->
      get conn, team_page_path(conn, :show, "unknown-team-slug")
    end
  end

  @tag login: true
  test "renders form for editing chosen resource", %{conn: conn, current_user: _current_user, valid_attrs: _valid_attrs} do
    team = insert(:team)
    conn = get conn, team_path(conn, :edit, team)
    assert html_response(conn, 200) =~ "Edit Team"
  end

  @tag login: true
  test "updates chosen resource and redirects when data is valid", %{conn: conn, current_user: _current_user, valid_attrs: _valid_attrs} do
    team = insert(:team)
    conn = put conn, team_path(conn, :update, team), team: @valid_attrs
    assert redirected_to(conn) == team_path(conn, :index) <> "#team-#{team.id}"
    assert Repo.get_by(Team, @valid_attrs)
  end

  @tag login: true
  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn, current_user: _current_user, valid_attrs: _valid_attrs} do
    team = insert(:team)
    conn = put conn, team_path(conn, :update, team), team: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit Team"
  end

  @tag login: true
  test "try to delete chosen resource", %{conn: conn, current_user: _current_user, valid_attrs: _valid_attrs} do
    team = insert(:team)
    conn = delete conn, team_path(conn, :delete, team)
    assert redirected_to(conn) == team_path(conn, :index)
    refute Repo.get(Team, team.id)
  end
end
