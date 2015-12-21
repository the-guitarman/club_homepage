defmodule ClubHomepage.UserControllerTest do
  use ClubHomepage.ConnCase

  alias ClubHomepage.User

  import ClubHomepage.Factory

  @valid_attrs %{birthday: "17.04.1988", email: "mail@example.de", login: "my_login", name: "some content", password: "my name"}
  @invalid_attrs %{}

  setup do
    conn = conn()
    {:ok, conn: conn}
  end

  test "try to lists all entries on index without login", %{conn: conn} do
    conn = get conn, managed_user_path(conn, :index)
    assert redirected_to(conn) =~ "/"
  end

  test "try to lists all entries on index with login", %{conn: conn} do
    conn = login(conn)
    conn = get conn, managed_user_path(conn, :index)
    assert html_response(conn, 200) =~ "Listing users"
  end

  test "renders form for new users without secret parameter", %{conn: conn} do
    conn = get conn, user_path(conn, :new)
    assert html_response(conn, 200) =~ "Jetzt registrieren"
  end

  test "renders form for new users with secret parameter", %{conn: conn} do
    conn = get conn, user_path(conn, :new, secret: "sdkljsdflksdjfisd")
    assert html_response(conn, 200) =~ "Jetzt registrieren"
  end

  test "creates resource and redirects when data is valid", %{conn: conn} do
    conn = post conn, user_path(conn, :create), user: @valid_attrs
    assert html_response(conn, 200) =~ "Jetzt registrieren"
    assert html_response(conn, 200) =~ "Secret wird benötigt"

    secret = create(:secret)
    new_valid_attrs = Map.put(@valid_attrs, :secret, secret.key)
    conn = post conn, user_path(conn, :create), user: new_valid_attrs

    assert redirected_to(conn) == page_path(conn, :index)
    user = Repo.get_by(User, login: @valid_attrs.login)
    assert user.active
    assert user.id == conn.assigns.current_user.id
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, user_path(conn, :create), user: @invalid_attrs
    assert html_response(conn, 200) =~ "Jetzt registrieren"
    assert html_response(conn, 200) =~ "Secret wird benötigt"
    assert html_response(conn, 200) =~ "Login can&#39;t be blank"
    assert html_response(conn, 200) =~ "Name can&#39;t be blank"
    assert html_response(conn, 200) =~ "Email can&#39;t be blank"
    assert html_response(conn, 200) =~ "Birthday can&#39;t be blank"
  end

  test "show a user without current_user is logged in", %{conn: conn} do
    user = create(:user)
    conn = get conn, managed_user_path(conn, :show, user)
    assert redirected_to(conn) =~ "/"
  end

  test "show a user with current_user is logged in", %{conn: conn} do
    conn = login(conn)

    user = create(:user)
    conn = get conn, managed_user_path(conn, :show, user)
    assert html_response(conn, 200) =~ "Show user"
  end

  test "renders page not found when id is nonexistent without current_user is logged in", %{conn: conn} do
    conn = get conn, managed_user_path(conn, :show, -1)
    assert redirected_to(conn) =~ "/"
  end

  test "renders page not found when id is nonexistent with current_user is logged in", %{conn: conn} do
    conn = login(conn)

    assert_raise Ecto.NoResultsError, fn ->
      get conn, managed_user_path(conn, :show, -1)
    end
  end

  # test "renders form for editing chosen resource", %{conn: conn} do
  #   user = Repo.insert! %User{}
  #   conn = get conn, user_path(conn, :edit, user)
  #   assert html_response(conn, 200) =~ "Edit user"
  # end

  # test "updates chosen resource and redirects when data is valid", %{conn: conn} do
  #   user = Repo.insert! %User{}
  #   conn = put conn, user_path(conn, :update, user), user: @valid_attrs
  #   assert redirected_to(conn) == user_path(conn, :show, user)
  #   assert Repo.get_by(User, @valid_attrs)
  # end

  # test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
  #   user = Repo.insert! %User{}
  #   conn = put conn, user_path(conn, :update, user), user: @invalid_attrs
  #   assert html_response(conn, 200) =~ "Edit user"
  # end

  # test "deletes chosen resource", %{conn: conn} do
  #   user = Repo.insert! %User{}
  #   conn = delete conn, user_path(conn, :delete, user)
  #   assert redirected_to(conn) == user_path(conn, :index)
  #   refute Repo.get(User, user.id)
  # end

  defp login(conn) do
    user = create(:user)
    assign(conn, :current_user, user)
  end
end
