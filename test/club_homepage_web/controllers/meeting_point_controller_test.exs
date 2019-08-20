defmodule ClubHomepage.MeetingPointControllerTest do
  use ClubHomepage.Web.ConnCase

  alias ClubHomepage.MeetingPoint

  import ClubHomepage.Factory

  @valid_attrs %{name: "Club House", address_id: 1}
  @invalid_attrs %{}

  setup context do
    conn = build_conn()
    address = insert(:address)
    valid_attrs = %{@valid_attrs | address_id: address.id}
    if context[:login] do
      current_user = insert(:user)
      conn = assign(conn, :current_user, current_user)
      {:ok, conn: conn, current_user: current_user, valid_attrs: valid_attrs}
    else
      {:ok, conn: conn, valid_attrs: valid_attrs}
    end
  end

  @tag login: false
  test "requires user authentication on all actions", %{conn: conn, valid_attrs: valid_attrs} do
    meeting_point = insert(:meeting_point)
    Enum.each([
      get(conn, meeting_point_path(conn, :index)),
      get(conn, meeting_point_path(conn, :new)),
      post(conn, meeting_point_path(conn, :create), meeting_point: valid_attrs),
      get(conn, meeting_point_path(conn, :edit, meeting_point)),
      put(conn, meeting_point_path(conn, :update, meeting_point), meeting_point: valid_attrs),
      put(conn, meeting_point_path(conn, :update, meeting_point), meeting_point: @invalid_attrs),
      delete(conn, meeting_point_path(conn, :delete, meeting_point))
    ], fn conn ->
      assert html_response(conn, 302)
      assert conn.halted
      assert redirected_to(conn) =~ "/"
    end)
  end

  @tag login: true
  test "lists all entries on index", %{conn: conn, current_user: _current_user, valid_attrs: _valid_attrs} do
    conn = get conn, meeting_point_path(conn, :index)
    assert html_response(conn, 200) =~ "All Meeting Points"
  end

  @tag login: true
  test "renders form for new resources", %{conn: conn, current_user: _current_user, valid_attrs: _valid_attrs} do
    conn = get conn, meeting_point_path(conn, :new)
    assert html_response(conn, 200) =~ "Create Meeting Point"
  end

  @tag login: true
  test "creates resource and redirects when data is valid", %{conn: conn, current_user: _current_user, valid_attrs: valid_attrs} do

    conn = post conn, meeting_point_path(conn, :create), meeting_point: valid_attrs
    assert redirected_to(conn) == meeting_point_path(conn, :index) <> "#meeting-point-#{get_highest_id(MeetingPoint)}"
    assert Repo.get_by(MeetingPoint, valid_attrs)
  end

  @tag login: true
  test "does not create resource and renders errors when data is invalid", %{conn: conn, current_user: _current_user, valid_attrs: _valid_attrs} do
    conn = post conn, meeting_point_path(conn, :create), meeting_point: @invalid_attrs
    assert html_response(conn, 200) =~ "Create Meeting Point"
  end

  @tag login: true
  test "renders form for editing chosen resource", %{conn: conn, current_user: _current_user, valid_attrs: _valid_attrs} do
    meeting_point = Repo.insert! %MeetingPoint{}
    conn = get conn, meeting_point_path(conn, :edit, meeting_point)
    assert html_response(conn, 200) =~ "Edit Meeting Point"
  end

  @tag login: true
  test "updates chosen resource and redirects when data is valid", %{conn: conn, current_user: _current_user, valid_attrs: valid_attrs} do
    meeting_point = Repo.insert! %MeetingPoint{}
    conn = put conn, meeting_point_path(conn, :update, meeting_point), meeting_point: valid_attrs
    assert redirected_to(conn) == meeting_point_path(conn, :index) <> "#meeting-point-#{meeting_point.id}"
    assert Repo.get_by(MeetingPoint, valid_attrs)
  end

  @tag login: true
  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn, current_user: _current_user, valid_attrs: _valid_attrs} do
    meeting_point = Repo.insert! %MeetingPoint{}
    conn = put conn, meeting_point_path(conn, :update, meeting_point), meeting_point: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit Meeting Point"
  end

  @tag login: true
  test "deletes chosen resource", %{conn: conn, current_user: _current_user, valid_attrs: _valid_attrs} do
    meeting_point = Repo.insert! %MeetingPoint{}
    conn = delete conn, meeting_point_path(conn, :delete, meeting_point)
    assert redirected_to(conn) == meeting_point_path(conn, :index)
    refute Repo.get(MeetingPoint, meeting_point.id)
  end
end
