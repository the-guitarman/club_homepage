defmodule ClubHomepage.BeerListControllerTest do
  use ClubHomepage.ConnCase

  alias ClubHomepage.BeerList
  @valid_attrs %{title: "Team 1", price_per_beer: 1.5}
  @invalid_attrs %{title: "", price_per_beer: nil}

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
