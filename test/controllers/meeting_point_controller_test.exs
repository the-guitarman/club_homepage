defmodule ClubHomepage.MeetingPointControllerTest do
  use ClubHomepage.ConnCase

  alias ClubHomepage.MeetingPoint
  @valid_attrs %{}
  @invalid_attrs %{}

  setup do
    conn = conn()
    {:ok, conn: conn}
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, meeting_point_path(conn, :index)
    assert html_response(conn, 200) =~ "Listing meeting points"
  end

  test "renders form for new resources", %{conn: conn} do
    conn = get conn, meeting_point_path(conn, :new)
    assert html_response(conn, 200) =~ "New meeting point"
  end

  test "creates resource and redirects when data is valid", %{conn: conn} do
    conn = post conn, meeting_point_path(conn, :create), meeting_point: @valid_attrs
    assert redirected_to(conn) == meeting_point_path(conn, :index)
    assert Repo.get_by(MeetingPoint, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, meeting_point_path(conn, :create), meeting_point: @invalid_attrs
    assert html_response(conn, 200) =~ "New meeting point"
  end

  test "shows chosen resource", %{conn: conn} do
    meeting_point = Repo.insert! %MeetingPoint{}
    conn = get conn, meeting_point_path(conn, :show, meeting_point)
    assert html_response(conn, 200) =~ "Show meeting point"
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_raise Ecto.NoResultsError, fn ->
      get conn, meeting_point_path(conn, :show, -1)
    end
  end

  test "renders form for editing chosen resource", %{conn: conn} do
    meeting_point = Repo.insert! %MeetingPoint{}
    conn = get conn, meeting_point_path(conn, :edit, meeting_point)
    assert html_response(conn, 200) =~ "Edit meeting point"
  end

  test "updates chosen resource and redirects when data is valid", %{conn: conn} do
    meeting_point = Repo.insert! %MeetingPoint{}
    conn = put conn, meeting_point_path(conn, :update, meeting_point), meeting_point: @valid_attrs
    assert redirected_to(conn) == meeting_point_path(conn, :show, meeting_point)
    assert Repo.get_by(MeetingPoint, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    meeting_point = Repo.insert! %MeetingPoint{}
    conn = put conn, meeting_point_path(conn, :update, meeting_point), meeting_point: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit meeting point"
  end

  test "deletes chosen resource", %{conn: conn} do
    meeting_point = Repo.insert! %MeetingPoint{}
    conn = delete conn, meeting_point_path(conn, :delete, meeting_point)
    assert redirected_to(conn) == meeting_point_path(conn, :index)
    refute Repo.get(MeetingPoint, meeting_point.id)
  end
end
