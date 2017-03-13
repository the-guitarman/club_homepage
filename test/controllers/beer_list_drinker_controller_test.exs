defmodule ClubHomepage.BeerListDrinkerControllerTest do
  use ClubHomepage.ConnCase

  alias ClubHomepage.BeerListDrinker
  @valid_attrs %{beers: 42}
  @invalid_attrs %{}

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, beer_list_drinker_path(conn, :index)
    assert html_response(conn, 200) =~ "Listing beer list drinkers"
  end

  test "renders form for new resources", %{conn: conn} do
    conn = get conn, beer_list_drinker_path(conn, :new)
    assert html_response(conn, 200) =~ "New beer list drinker"
  end

  test "creates resource and redirects when data is valid", %{conn: conn} do
    conn = post conn, beer_list_drinker_path(conn, :create), beer_list_drinker: @valid_attrs
    assert redirected_to(conn) == beer_list_drinker_path(conn, :index)
    assert Repo.get_by(BeerListDrinker, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, beer_list_drinker_path(conn, :create), beer_list_drinker: @invalid_attrs
    assert html_response(conn, 200) =~ "New beer list drinker"
  end

  test "shows chosen resource", %{conn: conn} do
    beer_list_drinker = Repo.insert! %BeerListDrinker{}
    conn = get conn, beer_list_drinker_path(conn, :show, beer_list_drinker)
    assert html_response(conn, 200) =~ "Show beer list drinker"
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, beer_list_drinker_path(conn, :show, -1)
    end
  end

  test "renders form for editing chosen resource", %{conn: conn} do
    beer_list_drinker = Repo.insert! %BeerListDrinker{}
    conn = get conn, beer_list_drinker_path(conn, :edit, beer_list_drinker)
    assert html_response(conn, 200) =~ "Edit beer list drinker"
  end

  test "updates chosen resource and redirects when data is valid", %{conn: conn} do
    beer_list_drinker = Repo.insert! %BeerListDrinker{}
    conn = put conn, beer_list_drinker_path(conn, :update, beer_list_drinker), beer_list_drinker: @valid_attrs
    assert redirected_to(conn) == beer_list_drinker_path(conn, :show, beer_list_drinker)
    assert Repo.get_by(BeerListDrinker, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    beer_list_drinker = Repo.insert! %BeerListDrinker{}
    conn = put conn, beer_list_drinker_path(conn, :update, beer_list_drinker), beer_list_drinker: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit beer list drinker"
  end

  test "deletes chosen resource", %{conn: conn} do
    beer_list_drinker = Repo.insert! %BeerListDrinker{}
    conn = delete conn, beer_list_drinker_path(conn, :delete, beer_list_drinker)
    assert redirected_to(conn) == beer_list_drinker_path(conn, :index)
    refute Repo.get(BeerListDrinker, beer_list_drinker.id)
  end
end
