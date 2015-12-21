defmodule ClubHomepage.SeasonControllerTest do
  use ClubHomepage.ConnCase

  alias ClubHomepage.Season

  import ClubHomepage.Factory
  import Extension.SeasonController

  @valid_attrs %{name: "2015-2016"}
  @invalid_attrs %{}

  setup do
    conn = conn()
    {:ok, conn: conn}
  end

  test "lists all entries on index without login", %{conn: conn} do
    conn = get conn, season_path(conn, :index)
    assert redirected_to(conn) == "/"
  end

  test "lists all entries on index with login", %{conn: conn} do
    conn = login(conn)
    conn = get conn, season_path(conn, :index)
    assert html_response(conn, 200) =~ "Alle Saisons"
  end

  test "renders form for new resources without login", %{conn: conn} do
    conn = get conn, season_path(conn, :new)
    assert redirected_to(conn) == "/"
  end

  test "renders form for new resources with login", %{conn: conn} do
    conn = login(conn)
    conn = get conn, season_path(conn, :new)
    assert html_response(conn, 200) =~ "Neue Saison anlegen"
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
    assert html_response(conn, 200) =~ "Neue Saison anlegen"
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
