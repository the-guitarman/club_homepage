defmodule ClubHomepage.MeetingPointControllerTest do
  use ClubHomepage.ConnCase

  alias ClubHomepage.MeetingPoint

  import ClubHomepage.Factory

  @valid_attrs %{name: "Club House", address_id: 1}
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
  test "requires user authentication on all actions", %{conn: conn, current_user: _current_user} do
    meeting_point = create(:meeting_point)
    Enum.each([
      get(conn, meeting_point_path(conn, :index)),
      get(conn, meeting_point_path(conn, :new)),
      post(conn, meeting_point_path(conn, :create), meeting_point: @valid_attrs),
      get(conn, meeting_point_path(conn, :edit, meeting_point)),
      put(conn, meeting_point_path(conn, :update, meeting_point), meeting_point: @valid_attrs),
      put(conn, meeting_point_path(conn, :update, meeting_point), meeting_point: @invalid_attrs),
      get(conn, meeting_point_path(conn, :show, meeting_point)),
      get(conn, meeting_point_path(conn, :show, -1)),
      get(conn, meeting_point_path(conn, :delete, meeting_point))
    ], fn conn ->
      assert html_response(conn, 302)
      assert conn.halted
      assert redirected_to(conn) =~ "/"
    end)
  end

  @tag login: true
  test "lists all entries on index", %{conn: conn, current_user: _current_user} do
    conn = get conn, meeting_point_path(conn, :index)
    assert html_response(conn, 200) =~ "All Meeting Points"
  end

  @tag login: true
  test "renders form for new resources", %{conn: conn, current_user: _current_user} do
    conn = get conn, meeting_point_path(conn, :new)
    assert html_response(conn, 200) =~ "Create Meeting Point"
  end

  @tag login: true
  test "creates resource and redirects when data is valid", %{conn: conn, current_user: _current_user} do
    conn = post conn, meeting_point_path(conn, :create), meeting_point: @valid_attrs
    assert redirected_to(conn) == meeting_point_path(conn, :index)
    assert Repo.get_by(MeetingPoint, @valid_attrs)
  end

  @tag login: true
  test "does not create resource and renders errors when data is invalid", %{conn: conn, current_user: _current_user} do
    conn = post conn, meeting_point_path(conn, :create), meeting_point: @invalid_attrs
    assert html_response(conn, 200) =~ "Create Meeting Point"
  end

  @tag login: true
  test "shows chosen resource", %{conn: conn, current_user: _current_user} do
    meeting_point = Repo.insert! %MeetingPoint{}
    conn = get conn, meeting_point_path(conn, :show, meeting_point)
    assert html_response(conn, 200) =~ "Show Meeting Point"
  end

  @tag login: true
  test "renders page not found when id is nonexistent", %{conn: conn, current_user: _current_user} do
    assert_raise Ecto.NoResultsError, fn ->
      get conn, meeting_point_path(conn, :show, -1)
    end
  end

  @tag login: true
  test "renders form for editing chosen resource", %{conn: conn, current_user: _current_user} do
    meeting_point = Repo.insert! %MeetingPoint{}
    conn = get conn, meeting_point_path(conn, :edit, meeting_point)
    assert html_response(conn, 200) =~ "Edit Meeting Point"
  end

  @tag login: true
  test "updates chosen resource and redirects when data is valid", %{conn: conn, current_user: _current_user} do
    meeting_point = Repo.insert! %MeetingPoint{}
    conn = put conn, meeting_point_path(conn, :update, meeting_point), meeting_point: @valid_attrs
    assert redirected_to(conn) == meeting_point_path(conn, :show, meeting_point)
    assert Repo.get_by(MeetingPoint, @valid_attrs)
  end

  @tag login: true
  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn, current_user: _current_user} do
    meeting_point = Repo.insert! %MeetingPoint{}
    conn = put conn, meeting_point_path(conn, :update, meeting_point), meeting_point: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit Meeting Point"
  end

  @tag login: true
  test "deletes chosen resource", %{conn: conn, current_user: _current_user} do
    meeting_point = Repo.insert! %MeetingPoint{}
    conn = delete conn, meeting_point_path(conn, :delete, meeting_point)
    assert redirected_to(conn) == meeting_point_path(conn, :index)
    refute Repo.get(MeetingPoint, meeting_point.id)
  end
end
