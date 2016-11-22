defmodule ClubHomepage.SecretControllerTest do
  use ClubHomepage.ConnCase
  use Bamboo.Test

  alias ClubHomepage.Secret

  import ClubHomepage.Factory

  @valid_attrs %{}
  @invalid_attrs %{email: "test[at]example_com"}

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
    secret = insert(:secret)
    Enum.each([
      #get(conn, secret_path(conn, :index)),
      get(conn, secret_path(conn, :new)),
      post(conn, secret_path(conn, :create), secret: @valid_attrs),
      post(conn, secret_path(conn, :create), secret: @invalid_attrs),
      delete(conn, secret_path(conn, :delete, secret))
    ], fn conn ->
      assert html_response(conn, 302)
      assert conn.halted
      assert redirected_to(conn) =~ "/"
    end)
  end

  @tag login: true
  test "lists all entries on index", %{conn: conn, current_user: _current_user} do
    conn = get conn, secret_path(conn, :index)
    assert html_response(conn, 200) =~ "<h2>All Secrets</h2>"
  end

  @tag login: true
  test "show a secret", %{conn: conn, current_user: _current_user} do
    secret = insert(:secret)
    conn = get conn, secret_path(conn, :show, secret)
    assert html_response(conn, 200) =~ "<h2>Secret</h2>"
  end

  @tag login: true
  test "renders form for new secret with current_user is logged in", %{conn: conn, current_user: _current_user} do
    conn = get conn, secret_path(conn, :new)
    assert html_response(conn, 200) =~ "Save"
  end

  @tag login: true
  test "creates resource and redirects when data is valid and current_user is logged in", %{conn: conn, current_user: _current_user} do
    conn = post conn, secret_path(conn, :create), secret: @valid_attrs
    secret = Repo.get_by(Secret, @valid_attrs)
    assert secret
    assert redirected_to(conn) == secret_path(conn, :show, secret)
    assert_no_emails_delivered
  end

  @tag login: true
  test "creates resource with valid email and redirects when data is valid and current_user is logged in", %{conn: conn, current_user: _current_user} do
    valid_attrs = Map.put(@valid_attrs, :email, "test@example.com")
    conn = post conn, secret_path(conn, :create), secret: valid_attrs
    secret = Repo.get_by(Secret, valid_attrs)
    assert secret
    assert redirected_to(conn) == secret_path(conn, :show, secret)
    assert_delivered_email ClubHomepage.Email.secret_text_email(conn, secret)
  end

  @tag login: true
  test "does not create resource and renders errors when data is invalid and current_user is logged in", %{conn: conn, current_user: _current_user} do
    conn = post conn, secret_path(conn, :create), secret: @invalid_attrs
    secret = Repo.get_by(Secret, @invalid_attrs)
    assert secret == nil
    assert html_response(conn, 200) =~ "email has invalid format"
  end

  # @tag login: true
  # test "deletes chosen resource", %{conn: conn, current_user: _current_user} do
  #   changeset = Secret.changeset(%Secret{}, @valid_attrs)
  #   secret = Repo.insert!(changeset)

  #   #secret = Repo.insert! %Secret{}
  #   conn = delete conn, secret_path(conn, :delete, secret)
  #   assert redirected_to(conn) == secret_path(conn, :index)
  #   refute Repo.get(Secret, secret.id)
  # end
end
