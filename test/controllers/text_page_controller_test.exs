defmodule ClubHomepage.TextPageControllerTest do
  use ClubHomepage.ConnCase

  alias ClubHomepage.TextPage

  import ClubHomepage.Factory

  @valid_attrs %{key: "some content", text: "some content"}
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
    text_page = create(:text_page)
    Enum.each([
      get(conn, text_page_path(conn, :index)),
 #     get(conn, text_page_path(conn, :new)),
 #     post(conn, text_page_path(conn, :create), text_page: @valid_attrs),
 #     post(conn, text_page_path(conn, :create), text_page: @invalid_attrs),
      get(conn, text_page_path(conn, :edit, text_page)),
      put(conn, text_page_path(conn, :update, text_page), text_page: @valid_attrs),
      put(conn, text_page_path(conn, :update, text_page), text_page: @invalid_attrs),
      get(conn, text_page_path(conn, :show, text_page)),
      get(conn, text_page_path(conn, :show, -1)),
 #     delete(conn, text_page_path(conn, :delete, text_page))
    ], fn conn ->
      assert html_response(conn, 302)
      assert conn.halted
      assert redirected_to(conn) =~ "/"
    end)
  end

  @tag login: true
  test "lists all entries on index", %{conn: conn} do
    conn = get conn, text_page_path(conn, :index)
    assert html_response(conn, 200) =~ "Listing text pages"
  end

  # @tag login: true
  # test "renders form for new resources", %{conn: conn} do
  #   conn = get conn, text_page_path(conn, :new)
  #   assert html_response(conn, 200) =~ "New text page"
  # end

  # @tag login: true
  # test "creates resource and redirects when data is valid", %{conn: conn} do
  #   conn = post conn, text_page_path(conn, :create), text_page: @valid_attrs
  #   assert redirected_to(conn) == text_page_path(conn, :index)
  #   assert Repo.get_by(TextPage, @valid_attrs)
  # end

  # @tag login: true
  # test "does not create resource and renders errors when data is invalid", %{conn: conn} do
  #   conn = post conn, text_page_path(conn, :create), text_page: @invalid_attrs
  #   assert html_response(conn, 200) =~ "New text page"
  # end

  @tag login: true
  test "shows chosen resource", %{conn: conn} do
    text_page = Repo.insert! %TextPage{}
    conn = get conn, text_page_path(conn, :show, text_page)
    assert html_response(conn, 200) =~ "Show text page"
  end

  @tag login: true
  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, text_page_path(conn, :show, -1)
    end
  end

  @tag login: true
  test "renders form for editing chosen resource", %{conn: conn} do
    text_page = Repo.insert! %TextPage{}
    conn = get conn, text_page_path(conn, :edit, text_page)
    assert html_response(conn, 200) =~ "Edit text page"
  end

  @tag login: true
  test "updates chosen resource and redirects when data is valid", %{conn: conn} do
    text_page = Repo.insert! %TextPage{}
    conn = put conn, text_page_path(conn, :update, text_page), text_page: @valid_attrs
    assert redirected_to(conn) == text_page_path(conn, :show, text_page)
    assert Repo.get_by(TextPage, @valid_attrs)
  end

  @tag login: true
  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    text_page = Repo.insert! %TextPage{}
    conn = put conn, text_page_path(conn, :update, text_page), text_page: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit text page"
  end

  # @tag login: true
  # test "deletes chosen resource", %{conn: conn} do
  #   text_page = Repo.insert! %TextPage{}
  #   conn = delete conn, text_page_path(conn, :delete, text_page)
  #   assert redirected_to(conn) == text_page_path(conn, :index)
  #   refute Repo.get(TextPage, text_page.id)
  # end
end
