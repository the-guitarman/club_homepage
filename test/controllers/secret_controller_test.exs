defmodule ClubHomepage.SecretControllerTest do
  use ClubHomepage.ConnCase

  alias ClubHomepage.Secret

  import ClubHomepage.Factory

  @valid_attrs %{}
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
    secret = create(:secret)
    Enum.each([
      #get(conn, secret_path(conn, :index)),
      get(conn, secret_path(conn, :new)),
      post(conn, secret_path(conn, :create), secret: @valid_attrs),
      post(conn, secret_path(conn, :create), secret: @invalid_attrs),
      #get(conn, secret_path(conn, :edit, secret)),
      #put(conn, secret_path(conn, :update, secret), secret: @valid_attrs),
      #put(conn, secret_path(conn, :update, secret), secret: @invalid_attrs),
      get(conn, secret_path(conn, :show, secret)),
      get(conn, secret_path(conn, :show, -1)),
      delete(conn, secret_path(conn, :delete, secret))
    ], fn conn ->
      assert html_response(conn, 302)
      assert conn.halted
      assert redirected_to(conn) =~ "/"
    end)
  end

  # @tag login: true
  # test "lists all entries on index", %{conn: conn, current_user: _current_user} do
  #   conn = get conn, secret_path(conn, :index)
  #   assert html_response(conn, 200) =~ "Listing secrets"
  # end

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
  end

  @tag login: true
  test "does not create resource and renders errors when data is invalid and current_user is logged in", %{conn: conn, current_user: _current_user} do
    conn = post conn, secret_path(conn, :create), secret: @invalid_attrs
    secret = Repo.get_by(Secret, @valid_attrs)
    assert secret
    assert redirected_to(conn) == secret_path(conn, :show, secret)
  end

  @tag login: true
  test "shows chosen resource with current_user is logged in", %{conn: conn, current_user: _current_user} do
    secret = create(:secret)
    conn = get conn, secret_path(conn, :show, secret)
    assert html_response(conn, 200) =~ "Secret"
  end

  @tag login: true
  test "renders page not found when id is nonexistent with current_user is logged in", %{conn: conn, current_user: _current_user} do
    assert_raise Ecto.NoResultsError, fn ->
      get conn, secret_path(conn, :show, -1)
    end
  end

  # @tag login: true
  # test "renders form for editing chosen resource", %{conn: conn, current_user: _current_user} do
  #   changeset = Secret.changeset(%Secret{}, @valid_attrs)
  #   secret = Repo.insert!(changeset)

  #   #secret = Repo.insert! %Secret{}
  #   conn = get conn, secret_path(conn, :edit, secret)
  #   assert html_response(conn, 200) =~ "Edit secret"
  # end

  # @tag login: true
  # test "updates chosen resource and redirects when data is valid", %{conn: conn, current_user: _current_user} do
  #   changeset = Secret.changeset(%Secret{}, @valid_attrs)
  #   secret = Repo.insert!(changeset)

  #   #secret = Repo.insert! %Secret{}
  #   conn = put conn, secret_path(conn, :update, secret), secret: @valid_attrs
  #   assert redirected_to(conn) == secret_path(conn, :show, secret)
  #   assert Repo.get_by(Secret, @valid_attrs)
  # end

  # @tag login: true
  # test "does not update chosen resource and renders errors when data is invalid", %{conn: conn, _current_user: current_user} do
  #   changeset = Secret.changeset(%Secret{}, @valid_attrs)
  #   secret = Repo.insert!(changeset)

  #   #secret = Repo.insert! %Secret{}
  #   conn = put conn, secret_path(conn, :update, secret), secret: @invalid_attrs
  #   assert html_response(conn, 302) =~ "You are being" #"Edit secret"
  # end

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
