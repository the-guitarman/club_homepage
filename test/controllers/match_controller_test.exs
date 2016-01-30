defmodule ClubHomepage.MatchControllerTest do
  use ClubHomepage.ConnCase

  alias ClubHomepage.Match

  import ClubHomepage.Factory

  import Ecto.Query, only: [from: 1, from: 2]

  @valid_attrs %{season_id: 1, team_id: 1, opponent_team_id: 1, home_match: true, start_at: "17.04.2010 14:00"}
  @invalid_attrs %{}

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
    user = create(:user)
    match = create(:match)
    Enum.each([
      get(conn, match_path(conn, :index)),
      get(conn, match_path(conn, :new)),
      post(conn, match_path(conn, :create), match: @valid_attrs),
      get(conn, match_path(conn, :show, match)),
      get(conn, match_path(conn, :edit, match)),
      put(conn, match_path(conn, :update, match), match: @valid_attrs),
      delete(conn, match_path(conn, :delete, match))
    ], fn conn ->
      assert html_response(conn, 302)
      assert conn.halted
      assert redirected_to(conn) =~ "/"
    end)
  end

  @tag login: true
  test "lists all entries on index with a user is logged in", %{conn: conn, current_user: _current_user} do
    conn = get conn, match_path(conn, :index)
    assert html_response(conn, 200) =~ "All Matches"
  end

  @tag login: true
  test "renders form for new resources with a user is logged in", %{conn: conn, current_user: _current_user} do
    conn = get conn, match_path(conn, :new)
    assert html_response(conn, 200) =~ "Create Match"
  end

  @tag login: true
  test "creates a match and redirects when data is valid and a user is logged in", %{conn: conn, current_user: _current_user} do
    query = from(m in Match, select: count(m.id))
    assert 0 == Repo.one(query)
    IO.puts "test"
    conn = post conn, match_path(conn, :create), match: @valid_attrs
    assert redirected_to(conn) == match_path(conn, :index)
    assert 1 == Repo.one(query)
  end

  @tag login: true
  test "does not create a match and renders errors when data is invalid and a user is logged in", %{conn: conn, current_user: _current_user} do
    conn = post conn, match_path(conn, :create), match: @invalid_attrs
    assert html_response(conn, 200) =~ "Create Match"
  end

  @tag login: true
  test "shows a match with a user is logged in", %{conn: conn, current_user: _current_user} do
    match = Repo.insert! %Match{}
    match = create(:match)
    conn = get conn, match_path(conn, :show, match)
    assert html_response(conn, 200) =~ "Show Match"
  end

  @tag login: true
  # test "tries to render page not found when id is nonexistent and no user is logged in", %{conn: conn, current_user: _current_user} do
  #   #assert_error_sent 404, fn ->
  #     get conn, match_path(conn, :show, -1)
  #   #end
  #   IO.inspect conn
  #   assert redirected_to(conn) =~ "/"
  # end

  @tag login: true
  test "renders page not found when id is nonexistent and a user is logged in", %{conn: conn, current_user: _current_user} do
    assert_raise Ecto.NoResultsError, fn ->
      get conn, match_path(conn, :show, -1)
    end
  end

  @tag login: true
  test "renders form for editing chosen resource with a user is logged in", %{conn: conn, current_user: _current_user} do
    match = Repo.insert! %Match{}
    conn = get conn, match_path(conn, :edit, match)
    assert html_response(conn, 200) =~ "Edit Match"
  end

  @tag login: true
  test "updates chosen resource and redirects when data is valid and a user is logged in", %{conn: conn, current_user: _current_user} do
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

  @tag login: true
  test "does not update chosen resource and renders errors when data is invalid a user is logged in", %{conn: conn, current_user: _current_user} do
    match = Repo.insert! %Match{}
    conn = put conn, match_path(conn, :update, match), match: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit Match"
  end

  @tag login: true
  test "deletes chosen resource with a user is logged in", %{conn: conn, current_user: _current_user} do
    match = Repo.insert! %Match{}
    conn = delete conn, match_path(conn, :delete, match)
    assert redirected_to(conn) == match_path(conn, :index)
    refute Repo.get(Match, match.id)
  end
end
