defmodule ClubHomepage.NewsControllerTest do
  use ClubHomepage.ConnCase

  alias ClubHomepage.News

  import ClubHomepage.Factory

  @valid_attrs %{body: "This is a message.", public: true, subject: "Subject"}
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
    news = insert(:news)
    Enum.each([
      get(conn, news_path(conn, :new)),
      post(conn, news_path(conn, :create), news: @valid_attrs),
      get(conn, news_path(conn, :show, news)),
      get(conn, news_path(conn, :edit, news)),
      put(conn, news_path(conn, :update, news), news: @valid_attrs),
      delete(conn, news_path(conn, :delete, news))
    ], fn conn ->
      assert html_response(conn, 302)
      assert conn.halted
      assert redirected_to(conn) =~ "/"
    end)
  end

  @tag login: true
  test "lists all entries on index", %{conn: conn, current_user: _current_user} do
    _news1 = insert(:news, public: true, body: "This is news message 1.")
    _news2 = insert(:news, public: false, body: "This is news message 2.")
    conn = get conn, news_path(conn, :index)
    assert html_response(conn, 200) =~ "<h2>Latest News</h2>"
    assert html_response(conn, 200) =~ "Create News</a>"
    assert html_response(conn, 200) =~ "Edit</a>"
    assert html_response(conn, 200) =~ "Delete</a>"
    assert html_response(conn, 200) =~ "This is news message 1."
    assert html_response(conn, 200) =~ "This is news message 2."
  end

  @tag login: false
  test "lists all public entries on index", %{conn: conn} do
    _news1 = insert(:news, public: true, body: "This is news message 1.")
    _news2 = insert(:news, public: false, body: "This is news message 2.")
    conn = get conn, news_path(conn, :index)
    assert html_response(conn, 200) =~ "<h2>Latest News</h2>"
    refute html_response(conn, 200) =~ "Create News</a>"
    refute html_response(conn, 200) =~ "Edit</a>"
    refute html_response(conn, 200) =~ "Delete</a>"
    assert html_response(conn, 200) =~ "This is news message 1."
    refute html_response(conn, 200) =~ "This is news message 2."
  end

  @tag login: true
  test "renders form for new resources", %{conn: conn, current_user: _current_user} do
    conn = get conn, news_path(conn, :new)
    assert html_response(conn, 200) =~ "<h2>Create News</h2>"
  end

  @tag login: true
  test "creates resource and redirects when data is valid", %{conn: conn, current_user: _current_user} do
    conn = post conn, news_path(conn, :create), news: @valid_attrs
    assert redirected_to(conn) == news_path(conn, :index)
    assert Repo.get_by(News, @valid_attrs)
  end

  @tag login: true
  test "does not create resource and renders errors when data is invalid", %{conn: conn, current_user: _current_user} do
    conn = post conn, news_path(conn, :create), news: @invalid_attrs
    assert html_response(conn, 200) =~ "<h2>Create News</h2>"
  end

  @tag login: true
  test "shows chosen resource", %{conn: conn, current_user: _current_user} do
    news = Repo.insert! %News{}
    conn = get conn, news_path(conn, :show, news)
    assert html_response(conn, 200) =~ "<h2>Show News</h2>"
  end

  @tag login: true
  test "re<h2>nders pag</h2>e not found when id is nonexistent", %{conn: conn, current_user: _current_user} do
    assert_error_sent 404, fn ->
      get conn, news_path(conn, :show, -1)
    end
  end

  @tag login: true
  test "renders form for editing chosen resource", %{conn: conn, current_user: _current_user} do
    news = Repo.insert! %News{}
    conn = get conn, news_path(conn, :edit, news)
    assert html_response(conn, 200) =~ "<h2>Edit News</h2>"
  end

  @tag login: true
  test "updates chosen resource and redirects when data is valid", %{conn: conn, current_user: _current_user} do
    news = Repo.insert! %News{}
    conn = put conn, news_path(conn, :update, news), news: @valid_attrs
    assert redirected_to(conn) == news_path(conn, :index) <> "#news-#{news.id}"
    assert Repo.get_by(News, @valid_attrs)
  end

  @tag login: true
  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn, current_user: _current_user} do
    news = Repo.insert! %News{}
    conn = put conn, news_path(conn, :update, news), news: @invalid_attrs
    assert html_response(conn, 200) =~ "<h2>Edit News</h2>"
  end

  @tag login: true
  test "deletes chosen resource", %{conn: conn, current_user: _current_user} do
    news = Repo.insert! %News{}
    conn = delete conn, news_path(conn, :delete, news)
    assert redirected_to(conn) == news_path(conn, :index)
    refute Repo.get(News, news.id)
  end
end
