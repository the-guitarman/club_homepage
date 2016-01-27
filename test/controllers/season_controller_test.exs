defmodule ClubHomepage.SeasonControllerTest do
  use ClubHomepage.ConnCase

  alias ClubHomepage.Season

  import ClubHomepage.Factory
  import Extension.SeasonController

  @valid_attrs %{name: "2015-2016"}
  @invalid_attrs %{name: "some name"}

  setup context do
    conn = conn()
    if context[:login] do
      current_user = create(:user)
      conn = assign(conn, :current_user, current_user)
      {:ok, conn: conn, current_user: current_user}
    else
      {:ok, conn: conn}
    end
  end

  @tag login: false
  test "requires user authentication on all actions", %{conn: conn} do
    season = create(:season)
    Enum.each([
      get(conn, season_path(conn, :index)),
      get(conn, season_path(conn, :new)),
      post(conn, season_path(conn, :create), season: @valid_attrs),
      post(conn, season_path(conn, :create), season: @invalid_attrs),
      #get(conn, season_path(conn, :edit, season)),
      #put(conn, season_path(conn, :update, season), season: @valid_attrs),
      #put(conn, season_path(conn, :update, season), season: @invalid_attrs),
      get(conn, season_path(conn, :show, season)),
      get(conn, season_path(conn, :show, -1)),
      delete(conn, season_path(conn, :delete, season))
    ], fn conn ->
      assert html_response(conn, 302)
      assert conn.halted
      assert redirected_to(conn) =~ "/"
    end)
  end

  @tag login: true
  test "lists all entries on index with login", %{conn: conn, current_user: _current_user} do
    conn = get conn, season_path(conn, :index)
    assert html_response(conn, 200) =~ "All Seasons"
  end

  @tag login: true
  test "renders form for new resources with login", %{conn: conn} do
    conn = get conn, season_path(conn, :new)
    assert html_response(conn, 200) =~ "Create Season"
  end

  test "creates resource and redirects when data is valid without login", %{conn: conn} do
    conn = post conn, season_path(conn, :create), season: @valid_attrs
    assert redirected_to(conn) == "/"
  end

  test "creates resource and redirects when data is valid with login", %{conn: conn} do
    conn = login(conn)
    conn = post conn, season_path(conn, :create), season: @valid_attrs
    assert redirected_to(conn) == season_path(conn, :index)
    assert Repo.get_by(Season, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid without login", %{conn: conn} do
    conn = post conn, season_path(conn, :create), season: @invalid_attrs
    assert redirected_to(conn) == "/"
  end

  test "does not create resource and renders errors when data is invalid with login", %{conn: conn} do
    conn = login(conn)
    conn = post conn, season_path(conn, :create), season: @invalid_attrs
    assert html_response(conn, 200) =~ "Create Season"
  end

  test "shows chosen resource without login", %{conn: conn} do
    season = Repo.insert! %Season{}
    conn = get conn, season_path(conn, :show, season)
    assert redirected_to(conn) == "/"
  end

  test "shows chosen resource with login", %{conn: conn} do
    conn = login(conn)
    season = Repo.insert! %Season{}
    conn = get conn, season_path(conn, :show, season)
    assert html_response(conn, 200) =~ "Show season"
  end

  test "renders page not found when id is nonexistent without login", %{conn: conn} do
    conn = get conn, season_path(conn, :show, -1)
    assert redirected_to(conn) == "/"
  end

  test "renders page not found when id is nonexistent with login", %{conn: conn} do
    conn = login(conn)
    assert_raise Ecto.NoResultsError, fn ->
      get conn, season_path(conn, :show, -1)
    end
  end

  test "renders form for editing chosen resource without login", %{conn: conn} do
    season = Repo.insert! %Season{}
    conn = get conn, season_path(conn, :edit, season)
    assert redirected_to(conn) == "/"
  end

  test "renders form for editing chosen resource with login", %{conn: conn} do
    conn = login(conn)
    conn = assign(conn, :years, new_years(2015))
    season = Repo.insert! %Season{}
    conn = get conn, season_path(conn, :edit, season)
    assert html_response(conn, 200) =~ "Edit season"
  end

  test "updates chosen resource and redirects when data is valid without login", %{conn: conn} do
    season = Repo.insert! %Season{}
    conn = put conn, season_path(conn, :update, season), season: @valid_attrs
    assert redirected_to(conn) == "/"
  end

  test "updates chosen resource and redirects when data is valid with login", %{conn: conn} do
    conn = login(conn)
    season = Repo.insert! %Season{}
    conn = put conn, season_path(conn, :update, season), season: @valid_attrs
    assert redirected_to(conn) == season_path(conn, :show, season)
    assert Repo.get_by(Season, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid without login", %{conn: conn} do
    season = Repo.insert! %Season{}
    conn = put conn, season_path(conn, :update, season), season: @invalid_attrs
    assert redirected_to(conn) == "/"
  end

  test "does not update chosen resource and renders errors when data is invalid with login", %{conn: conn} do
    conn = login(conn)
    conn = assign(conn, :years, new_years(2015))
    season = Repo.insert! %Season{}
    conn = put conn, season_path(conn, :update, season), season: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit season"
  end

  test "deletes chosen resource without login", %{conn: conn} do
    season = Repo.insert! %Season{}
    conn = delete conn, season_path(conn, :delete, season)
    assert redirected_to(conn) == "/"
  end

  test "deletes chosen resource with login", %{conn: conn} do
    conn = login(conn)
    season = Repo.insert! %Season{}
    conn = delete conn, season_path(conn, :delete, season)
    assert redirected_to(conn) == season_path(conn, :index)
    refute Repo.get(Season, season.id)
  end

  defp login(conn) do
    user = create(:user)
    assign(conn, :current_user, user)
  end
end
