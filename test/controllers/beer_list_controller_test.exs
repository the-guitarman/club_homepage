defmodule ClubHomepage.BeerListControllerTest do
  use ClubHomepage.ConnCase

  alias ClubHomepage.BeerList

  import ClubHomepage.Factory

  import Ecto.Query, only: [from: 2]

  @valid_attrs %{title: "Team 1", price_per_beer: 1.5}
  @invalid_attrs %{title: "", price_per_beer: nil}

  setup context do
    conn = build_conn()
    user = insert(:user)
    valid_attrs = %{@valid_attrs | competition_id: competition.id, season_id: season.id, team_id: team.id, opponent_team_id: opponent_team.id}
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
  test "requires user authentication on all actions", %{conn: conn, valid_attrs: valid_attrs} do
    match = insert(:match)
    Enum.each([
      get(conn, match_path(conn, :index)),
      get(conn, match_path(conn, :new)),
      post(conn, match_path(conn, :create), match: valid_attrs),
      get(conn, match_path(conn, :edit, match)),
      put(conn, match_path(conn, :update, match), match: valid_attrs),
      delete(conn, match_path(conn, :delete, match))
    ], fn conn ->
      assert html_response(conn, 302)
      assert conn.halted
      assert redirected_to(conn) =~ "/"
    end)
  end

  @tag login: true
  test "lists all entries on index", %{conn: conn} do
    conn = get conn, beer_list_path(conn, :index)
    assert html_response(conn, 200) =~ "Listing beer lists"
  end

  test "renders form for new resources", %{conn: conn} do
    conn = get conn, beer_list_path(conn, :new)
    assert html_response(conn, 200) =~ "New beer list"
  end

  test "creates resource and redirects when data is valid", %{conn: conn} do
    conn = post conn, beer_list_path(conn, :create), beer_list: @valid_attrs
    assert redirected_to(conn) == beer_list_path(conn, :index)
    assert Repo.get_by(BeerList, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, beer_list_path(conn, :create), beer_list: @invalid_attrs
    assert html_response(conn, 200) =~ "New beer list"
  end

  test "shows chosen resource", %{conn: conn} do
    beer_list = Repo.insert! %BeerList{}
    conn = get conn, beer_list_path(conn, :show, beer_list)
    assert html_response(conn, 200) =~ "Show beer list"
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, beer_list_path(conn, :show, -1)
    end
  end

  test "renders form for editing chosen resource", %{conn: conn} do
    beer_list = Repo.insert! %BeerList{}
    conn = get conn, beer_list_path(conn, :edit, beer_list)
    assert html_response(conn, 200) =~ "Edit beer list"
  end

  test "updates chosen resource and redirects when data is valid", %{conn: conn} do
    beer_list = Repo.insert! %BeerList{}
    conn = put conn, beer_list_path(conn, :update, beer_list), beer_list: @valid_attrs
    assert redirected_to(conn) == beer_list_path(conn, :show, beer_list)
    assert Repo.get_by(BeerList, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    beer_list = Repo.insert! %BeerList{}
    conn = put conn, beer_list_path(conn, :update, beer_list), beer_list: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit beer list"
  end

  test "deletes chosen resource", %{conn: conn} do
    beer_list = Repo.insert! %BeerList{}
    conn = delete conn, beer_list_path(conn, :delete, beer_list)
    assert redirected_to(conn) == beer_list_path(conn, :index)
    refute Repo.get(BeerList, beer_list.id)
  end
end
