defmodule ClubHomepage.BeerListDrinkerControllerTest do
  use ClubHomepage.ConnCase

  alias ClubHomepage.BeerListDrinker

  import ClubHomepage.Factory

  import Ecto.Query, only: [from: 2]

  @valid_attrs %{beer_list_id: 1, user_id: 1, beers: 42}
  @invalid_attrs %{beer_list_id: 0, user_id: 0}

  setup context do
    conn = build_conn()
    beer_list = insert(:beer_list)
    user = insert(:user)
    valid_attrs = %{@valid_attrs | beer_list_id: beer_list.id, user_id: user.id}
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
    beer_list_drinker = insert(:beer_list_drinker)
    Enum.each([
      get(conn, beer_list_drinker_path(conn, :index)),
      get(conn, beer_list_drinker_path(conn, :show, beer_list_drinker)),
      get(conn, beer_list_drinker_path(conn, :new)),
      post(conn, beer_list_drinker_path(conn, :create), beer_list_drinker: valid_attrs),
      get(conn, beer_list_drinker_path(conn, :edit, beer_list_drinker)),
      put(conn, beer_list_drinker_path(conn, :update, beer_list_drinker), beer_list_drinker: valid_attrs),
      delete(conn, beer_list_drinker_path(conn, :delete, beer_list_drinker))
    ], fn conn ->
      assert html_response(conn, 302)
      assert conn.halted
      assert redirected_to(conn) =~ "/"
    end)
  end

  @tag login: true
  test "lists all entries on index", %{conn: conn} do
    conn = get conn, beer_list_drinker_path(conn, :index)
    assert html_response(conn, 200) =~ "Listing beer list drinkers"
  end

  @tag login: true
  test "renders form for new resources", %{conn: conn} do
    conn = get conn, beer_list_drinker_path(conn, :new)
    assert html_response(conn, 200) =~ "New beer list drinker"
  end

  @tag login: true
  test "creates resource and redirects when data is valid", %{conn: conn, valid_attrs: valid_attrs} do
    conn = post conn, beer_list_drinker_path(conn, :create), beer_list_drinker: valid_attrs
    assert redirected_to(conn) == page_path(conn, :index)
    assert Repo.get_by(BeerListDrinker, valid_attrs)
  end

  @tag login: true
  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, beer_list_drinker_path(conn, :create), beer_list_drinker: @invalid_attrs
    assert html_response(conn, 200) =~ "New beer list drinker"
  end

  @tag login: true
  test "shows chosen resource", %{conn: conn} do
    beer_list_drinker = insert(:beer_list_drinker)
    conn = get conn, beer_list_drinker_path(conn, :show, beer_list_drinker)
    assert html_response(conn, 200) =~ "Show beer list drinker"
  end

  @tag login: true
  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, beer_list_drinker_path(conn, :show, -1)
    end
  end

  @tag login: true
  test "renders form for editing chosen resource", %{conn: conn} do
    beer_list_drinker = insert(:beer_list_drinker)
    conn = get conn, beer_list_drinker_path(conn, :edit, beer_list_drinker)
    assert html_response(conn, 200) =~ "Edit beer list drinker"
  end

  @tag login: true
  test "updates chosen resource and redirects when data is valid", %{conn: conn, valid_attrs: valid_attrs} do
    beer_list_drinker = insert(:beer_list_drinker)
    conn = put conn, beer_list_drinker_path(conn, :update, beer_list_drinker), beer_list_drinker: valid_attrs
    assert redirected_to(conn) == page_path(conn, :index)
    assert Repo.get_by(BeerListDrinker, valid_attrs)
  end

  @tag login: true
  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    beer_list_drinker = insert(:beer_list_drinker)
    conn = put conn, beer_list_drinker_path(conn, :update, beer_list_drinker), beer_list_drinker: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit beer list drinker"
  end

  @tag login: true
  test "deletes chosen resource", %{conn: conn} do
    beer_list_drinker = insert(:beer_list_drinker)
    conn = delete conn, beer_list_drinker_path(conn, :delete, beer_list_drinker)
    assert redirected_to(conn) == beer_list_drinker_path(conn, :index)
    refute Repo.get(BeerListDrinker, beer_list_drinker.id)
  end
end
