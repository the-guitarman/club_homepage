defmodule ClubHomepage.PermalinkControllerTest do
  use ClubHomepage.Web.ConnCase

  alias ClubHomepage.Permalink

  import ClubHomepage.Factory

  @valid_attrs %{destination_path: "/teams/new", source_path: "/teams/old"}
  @invalid_attrs %{}

  setup context do
    conn = build_conn()
    team = insert(:team)
    valid_attrs = %{@valid_attrs | destination_path: team.slug}
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
    permalink = insert(:permalink)
    Enum.each([
      get(conn, permalink_path(conn, :index)),
      get(conn, permalink_path(conn, :new)),
      post(conn, permalink_path(conn, :create), permalink: valid_attrs),
      post(conn, permalink_path(conn, :create), permalink: @invalid_attrs),
      get(conn, permalink_path(conn, :edit, permalink)),
      put(conn, permalink_path(conn, :update, permalink), permalink: valid_attrs),
      put(conn, permalink_path(conn, :update, permalink), permalink: @invalid_attrs),
      get(conn, permalink_path(conn, :show, permalink)),
      get(conn, permalink_path(conn, :show, -1)),
      delete(conn, permalink_path(conn, :delete, permalink))
    ], fn conn ->
      assert html_response(conn, 302)
      assert conn.halted
      assert redirected_to(conn) =~ "/"
    end)
  end

  @tag login: true
  test "lists all entries on index", %{conn: conn, current_user: _current_user, valid_attrs: _valid_attrs} do
    conn = get conn, permalink_path(conn, :index)
    assert html_response(conn, 200) =~ "Listing permalinks"
  end

  @tag login: true
  test "renders form for new resources", %{conn: conn, current_user: _current_user, valid_attrs: _valid_attrs} do
    conn = get conn, permalink_path(conn, :new)
    assert html_response(conn, 200) =~ "New permalink"
  end

  @tag login: true
  test "creates resource and redirects when data is valid", %{conn: conn, current_user: _current_user, valid_attrs: valid_attrs} do
    conn = post conn, permalink_path(conn, :create), permalink: valid_attrs
    assert redirected_to(conn) == permalink_path(conn, :index)
    assert Repo.get_by(Permalink, valid_attrs)
  end

  @tag login: true
  test "does not create resource and renders errors when data is invalid", %{conn: conn, current_user: _current_user, valid_attrs: _valid_attrs} do
    conn = post conn, permalink_path(conn, :create), permalink: @invalid_attrs
    assert html_response(conn, 200) =~ "New permalink"
  end

  @tag login: true
  test "shows chosen resource", %{conn: conn, current_user: _current_user, valid_attrs: _valid_attrs} do
    permalink = Repo.insert! %Permalink{}
    conn = get conn, permalink_path(conn, :show, permalink)
    assert html_response(conn, 200) =~ "Show permalink"
  end

  @tag login: true
  test "renders page not found when id is nonexistent", %{conn: conn, current_user: _current_user, valid_attrs: _valid_attrs} do
    assert_error_sent 404, fn ->
      get conn, permalink_path(conn, :show, -1)
    end
  end

  @tag login: true
  test "renders form for editing chosen resource", %{conn: conn, current_user: _current_user, valid_attrs: _valid_attrs} do
    permalink = Repo.insert! %Permalink{}
    conn = get conn, permalink_path(conn, :edit, permalink)
    assert html_response(conn, 200) =~ "Edit permalink"
  end

  @tag login: true
  test "updates chosen resource and redirects when data is valid", %{conn: conn, current_user: _current_user, valid_attrs: valid_attrs} do
    permalink = Repo.insert! %Permalink{}
    conn = put conn, permalink_path(conn, :update, permalink), permalink: valid_attrs
    assert redirected_to(conn) == permalink_path(conn, :show, permalink)
    assert Repo.get_by(Permalink, valid_attrs)
  end

  @tag login: true
  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn, current_user: _current_user, valid_attrs: _valid_attrs} do
    permalink = Repo.insert! %Permalink{}
    conn = put conn, permalink_path(conn, :update, permalink), permalink: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit permalink"
  end

  @tag login: true
  test "deletes chosen resource", %{conn: conn, current_user: _current_user, valid_attrs: _valid_attrs} do
    permalink = Repo.insert! %Permalink{}
    conn = delete conn, permalink_path(conn, :delete, permalink)
    assert redirected_to(conn) == permalink_path(conn, :index)
    refute Repo.get(Permalink, permalink.id)
  end
end
