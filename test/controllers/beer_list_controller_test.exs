defmodule ClubHomepage.BeerListControllerTest do
  use ClubHomepage.ConnCase

  alias ClubHomepage.BeerList

  import ClubHomepage.Factory

  import Ecto.Query, only: [from: 2]

  @valid_attrs %{title: "Team 1", user_id: 1, price_per_beer: 1.5}
  @invalid_attrs %{title: "", price_per_beer: nil}

  setup context do
    conn = build_conn()
    user = insert(:user)
    valid_attrs = %{@valid_attrs | user_id: user.id}
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
    beer_list = insert(:beer_list)
    Enum.each([
      get(conn, beer_list_path(conn, :index)),
      get(conn, beer_list_path(conn, :show, beer_list)),
      get(conn, beer_list_path(conn, :new)),
      post(conn, beer_list_path(conn, :create), beer_list: valid_attrs),
      get(conn, beer_list_path(conn, :edit, beer_list)),
      put(conn, beer_list_path(conn, :update, beer_list), beer_list: valid_attrs),
      delete(conn, beer_list_path(conn, :delete, beer_list))
    ], fn conn ->
      assert html_response(conn, 302)
      assert conn.halted
      assert redirected_to(conn) =~ "/"
    end)
  end

  @tag login: true
  test "lists all entries on index", %{conn: conn} do
    conn = get conn, beer_list_path(conn, :index)
    assert html_response(conn, 200) =~ "All Beer Lists"
  end

  @tag login: true
  test "renders form for new resources", %{conn: conn} do
    conn = get conn, beer_list_path(conn, :new)
    assert html_response(conn, 200) =~ "Create Beer List"
  end

  @tag login: true
  test "creates resource and redirects when data is valid", %{conn: conn, valid_attrs: valid_attrs} do
    conn = post conn, beer_list_path(conn, :create), beer_list: valid_attrs
    assert redirected_to(conn) == page_path(conn, :index)
    assert Repo.get_by(BeerList, valid_attrs)
  end

  @tag login: true
  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, beer_list_path(conn, :create), beer_list: @invalid_attrs
    assert html_response(conn, 200) =~ "Create Beer List"
  end

  @tag login: true
  test "shows chosen resource", %{conn: conn} do
    beer_list = insert(:beer_list)
    conn = get conn, beer_list_path(conn, :show, beer_list)
    assert html_response(conn, 200) =~ "Beer List - #{beer_list.title}"
  end

  @tag login: true
  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, beer_list_path(conn, :show, -1)
    end
  end

  @tag login: true
  test "renders form for editing chosen resource", %{conn: conn} do
    beer_list = Repo.insert! %BeerList{}
    conn = get conn, beer_list_path(conn, :edit, beer_list)
    assert html_response(conn, 200) =~ "Edit Beer List"
  end

  @tag login: true
  test "updates chosen resource and redirects when data is valid", %{conn: conn, valid_attrs: valid_attrs} do
    beer_list = Repo.insert! %BeerList{}
    conn = put conn, beer_list_path(conn, :update, beer_list), beer_list: valid_attrs
    assert redirected_to(conn) == page_path(conn, :index)
    assert Repo.get_by(BeerList, valid_attrs)
  end

  @tag login: true
  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    beer_list = Repo.insert! %BeerList{}
    conn = put conn, beer_list_path(conn, :update, beer_list), beer_list: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit Beer List"
  end

  @tag login: true
  test "deletes chosen resource", %{conn: conn} do
    beer_list = Repo.insert! %BeerList{}
    conn = delete conn, beer_list_path(conn, :delete, beer_list)
    assert redirected_to(conn) == beer_list_path(conn, :index)
    refute Repo.get(BeerList, beer_list.id)
  end
end
