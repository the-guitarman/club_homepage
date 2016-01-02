defmodule ClubHomepage.MatchControllerTest do
  use ClubHomepage.ConnCase

  alias ClubHomepage.Match

#  import ClubHomepage.Factory
  import ClubHomepage.Test.Support.Auth

  import Ecto.Query, only: [from: 1, from: 2]

  @valid_attrs %{home_match: true, start_at: "17.04.2010 14:00:00"}
  @invalid_attrs %{}

  setup do
    conn = conn()
    {:ok, conn: conn}
  end

  test "tries to list all entries on index without a user is logged in", %{conn: conn} do
    conn = get conn, match_path(conn, :index)
    assert redirected_to(conn) =~ "/"
  end

  test "lists all entries on index with a user is logged in", %{conn: conn} do
    conn = login(conn)
    conn = get conn, match_path(conn, :index)
    assert html_response(conn, 200) =~ "Listing matches"
  end

  test "tries to render form for new resources witout a user is logged in", %{conn: conn} do
    conn = get conn, match_path(conn, :new)
    assert redirected_to(conn) =~ "/"
  end

  test "renders form for new resources with a user is logged in", %{conn: conn} do
    conn = login(conn)
    conn = get conn, match_path(conn, :new)
    assert html_response(conn, 200) =~ "New match"
  end

  test "tries to create a match and redirects when data is valid and no user is logged in", %{conn: conn} do
    conn = post conn, match_path(conn, :create), match: @valid_attrs
    assert redirected_to(conn) =~ "/"
  end

  test "creates a match and redirects when data is valid and a user is logged in", %{conn: conn} do
    query = from(m in Match, select: count(m.id))
    assert 0 == Repo.one(query)
    conn = login(conn)
    conn = post conn, match_path(conn, :create), match: @valid_attrs
    assert redirected_to(conn) == match_path(conn, :index)
    assert 1 == Repo.one(query)
  end

  test "does not create a match when data is invalid and no user is logged in", %{conn: conn} do
    conn = post conn, match_path(conn, :create), match: @invalid_attrs
    assert redirected_to(conn) =~ "/"
  end

  test "does not create a match and renders errors when data is invalid and a user is logged in", %{conn: conn} do
    conn = login(conn)
    conn = post conn, match_path(conn, :create), match: @invalid_attrs
    assert html_response(conn, 200) =~ "New match"
  end

  test "tries to show a match without a user is logged in", %{conn: conn} do
    match = Repo.insert! %Match{}
    conn = get conn, match_path(conn, :show, match)
    assert redirected_to(conn) =~ "/"
  end

  test "shows a match with a user is logged in", %{conn: conn} do
    conn = login(conn)
    match = Repo.insert! %Match{}
    conn = get conn, match_path(conn, :show, match)
    assert html_response(conn, 200) =~ "Show match"
  end

  # test "tries to render page not found when id is nonexistent and no user is logged in", %{conn: conn} do
  #   #assert_error_sent 404, fn ->
  #     get conn, match_path(conn, :show, -1)
  #   #end
  #   IO.inspect conn
  #   assert redirected_to(conn) =~ "/"
  # end

  test "renders page not found when id is nonexistent and a user is logged in", %{conn: conn} do
    conn = login(conn)
    assert_error_sent 404, fn ->
      get conn, match_path(conn, :show, -1)
    end
  end

  test "try to render form for editing chosen resource without a user is logged in", %{conn: conn} do
    match = Repo.insert! %Match{}
    conn = get conn, match_path(conn, :edit, match)
    assert redirected_to(conn) =~ "/"
  end

  test "renders form for editing chosen resource with a user is logged in", %{conn: conn} do
    conn = login(conn)
    match = Repo.insert! %Match{}
    conn = get conn, match_path(conn, :edit, match)
    assert html_response(conn, 200) =~ "Edit match"
  end

  test "tries to update chosen resource and redirects when data is valid and no user is logged in", %{conn: conn} do
    match = Repo.insert! %Match{}
    conn = put conn, match_path(conn, :update, match), match: @valid_attrs
    assert redirected_to(conn) =~ "/"
  end

  test "updates chosen resource and redirects when data is valid and a user is logged in", %{conn: conn} do
    conn = login(conn)
    query = from(m in Match, select: count(m.id), where: m.home_match == true)

    assert 0 == Repo.one(query)

    match = Repo.insert! %Match{home_match: true}
    assert match.home_match == true
    assert 1 == Repo.one(query)

    attributes = %{@valid_attrs | home_match: false}
    conn = put conn, match_path(conn, :update, match), match: attributes
    assert redirected_to(conn) == match_path(conn, :show, match)

    updated_match = Repo.get_by(Match, id: match.id)
    assert updated_match
    assert updated_match.home_match == false
    assert 0 == Repo.one(query)
  end

  test "does not update chosen resource when no user is logged in", %{conn: conn} do
    match = Repo.insert! %Match{}
    conn = put conn, match_path(conn, :update, match), match: @invalid_attrs
    assert redirected_to(conn) =~ "/"
  end

  test "does not update chosen resource and renders errors when data is invalid a user is logged in", %{conn: conn} do
    conn = login(conn)
    match = Repo.insert! %Match{}
    conn = put conn, match_path(conn, :update, match), match: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit match"
  end

  test "tries to delete chosen resource without a user is loghged in", %{conn: conn} do
    match = Repo.insert! %Match{}
    conn = delete conn, match_path(conn, :delete, match)
    assert redirected_to(conn) =~ "/"
  end

  test "deletes chosen resource with a user is logged in", %{conn: conn} do
    conn = login(conn)
    match = Repo.insert! %Match{}
    conn = delete conn, match_path(conn, :delete, match)
    assert redirected_to(conn) == match_path(conn, :index)
    refute Repo.get(Match, match.id)
  end
end
