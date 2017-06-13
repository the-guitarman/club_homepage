defmodule ClubHomepage.TextPageControllerTest do
  use ClubHomepage.Web.ConnCase

  alias ClubHomepage.TextPage

  import ClubHomepage.Factory

  @valid_attrs %{key: "some content", text: "some content"}
  @invalid_attrs %{}

  setup context do
    conn = build_conn()
    if context[:login] do
      current_user = insert(:user)
      conn = assign(conn, :current_user, current_user)
      {:ok, conn: conn, current_user: current_user}
    else
      {:ok, conn: conn}
    end
  end

  @tag login: false
  test "requires user authentication on all actions", %{conn: conn} do
    text_page = insert(:text_page)
    Enum.each([
      get(conn, text_page_path(conn, :index)),
      get(conn, text_page_path(conn, :edit, text_page)),
      put(conn, text_page_path(conn, :update, text_page), text_page: @valid_attrs),
      put(conn, text_page_path(conn, :update, text_page), text_page: @invalid_attrs)#,
    ], fn conn ->
      assert html_response(conn, 302)
      assert conn.halted
      assert redirected_to(conn) =~ "/"
    end)
  end

  @tag login: true
  test "lists all entries on index", %{conn: conn} do
    conn = get conn, text_page_path(conn, :index)
    assert html_response(conn, 200) =~ "<h2>All Text Pages</h2>"
  end

  @tag login: true
  test "renders form for editing chosen resource", %{conn: conn} do
    text_page = Repo.insert! %TextPage{}
    conn = get conn, text_page_path(conn, :edit, text_page)
    assert html_response(conn, 200) =~ "Edit Text Page"
  end

  @tag login: true
  test "updates chosen resource and redirects when data is valid", %{conn: conn} do
    text_page = Repo.insert! %TextPage{}
    conn = put conn, text_page_path(conn, :update, text_page), text_page: @valid_attrs
    assert redirected_to(conn) == text_page_path(conn, :index)
    assert Repo.get_by(TextPage, @valid_attrs)
  end

  @tag login: true
  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    text_page = Repo.insert! %TextPage{}
    conn = put conn, text_page_path(conn, :update, text_page), text_page: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit Text Page"
  end
end
