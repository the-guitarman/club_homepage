defmodule ClubHomepage.CompetitionControllerTest do
  use ClubHomepage.ConnCase

  alias ClubHomepage.Competition
  @valid_attrs %{name: "some content"}
  @invalid_attrs %{}

  import ClubHomepage.Factory

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
    competition = create(:competition)
    Enum.each([
      get(conn, competition_path(conn, :index)),
      get(conn, competition_path(conn, :new)),
      post(conn, competition_path(conn, :create), competition: @valid_attrs),
      get(conn, competition_path(conn, :show, competition)),
      get(conn, competition_path(conn, :edit, competition)),
      put(conn, competition_path(conn, :update, competition), competition: @valid_attrs),
      delete(conn, competition_path(conn, :delete, competition))
    ], fn conn ->
      assert html_response(conn, 302)
      assert conn.halted
      assert redirected_to(conn) =~ "/"
    end)
  end

  @tag login: true
  test "lists all entries on index", %{conn: conn, current_user: _current_user} do
    conn = get conn, competition_path(conn, :index)
    assert html_response(conn, 200) =~ "All Competitions"
  end

  @tag login: true
  test "renders form for new resources", %{conn: conn, current_user: _current_user} do
    conn = get conn, competition_path(conn, :new)
    assert html_response(conn, 200) =~ "Create Competition"
  end

  @tag login: true
  test "creates resource and redirects when data is valid", %{conn: conn, current_user: _current_user} do
    conn = post conn, competition_path(conn, :create), competition: @valid_attrs
    assert redirected_to(conn) == competition_path(conn, :index)
    assert Repo.get_by(Competition, @valid_attrs)
  end

  @tag login: true
  test "does not create resource and renders errors when data is invalid", %{conn: conn, current_user: _current_user} do
    conn = post conn, competition_path(conn, :create), competition: @invalid_attrs
    assert html_response(conn, 200) =~ "Create Competition"
  end

  @tag login: true
  test "shows chosen resource", %{conn: conn, current_user: _current_user} do
    competition = Repo.insert! %Competition{}
    conn = get conn, competition_path(conn, :show, competition)
    assert html_response(conn, 200) =~ "Competition"
  end

  @tag login: true
  test "renders page not found when id is nonexistent", %{conn: conn, current_user: _current_user} do
    assert_error_sent 404, fn ->
      get conn, competition_path(conn, :show, -1)
    end
  end

  @tag login: true
  test "renders form for editing chosen resource", %{conn: conn, current_user: _current_user} do
    competition = Repo.insert! %Competition{}
    conn = get conn, competition_path(conn, :edit, competition)
    assert html_response(conn, 200) =~ "Edit Competition"
  end

  @tag login: true
  test "updates chosen resource and redirects when data is valid", %{conn: conn, current_user: _current_user} do
    competition = Repo.insert! %Competition{}
    conn = put conn, competition_path(conn, :update, competition), competition: @valid_attrs
    assert redirected_to(conn) == competition_path(conn, :show, competition)
    assert Repo.get_by(Competition, @valid_attrs)
  end

  @tag login: true
  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn, current_user: _current_user} do
    competition = Repo.insert! %Competition{}
    conn = put conn, competition_path(conn, :update, competition), competition: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit Competition"
  end

  @tag login: true
  test "deletes chosen resource", %{conn: conn, current_user: _current_user} do
    competition = Repo.insert! %Competition{}
    conn = delete conn, competition_path(conn, :delete, competition)
    assert redirected_to(conn) == competition_path(conn, :index)
    refute Repo.get(Competition, competition.id)
  end
end
