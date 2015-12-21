defmodule ClubHomepage.SecretControllerTest do
  use ClubHomepage.ConnCase

  alias ClubHomepage.Secret

  import ClubHomepage.Factory

  @valid_attrs %{}
  @invalid_attrs %{}

  setup do
    conn = conn()
    {:ok, conn: conn}
  end

  # test "lists all entries on index", %{conn: conn} do
  #   conn = get conn, secret_path(conn, :index)
  #   assert html_response(conn, 200) =~ "Listing secrets"
  # end

  test "renders form for new secret without current_user is logged in", %{conn: conn} do
    conn = get conn, secret_path(conn, :new)
    assert redirected_to(conn) =~ "/"
  end

  test "renders form for new secret with current_user is logged in", %{conn: conn} do
    user = create(:user)
    conn = assign(conn, :current_user, user)
    conn = get conn, secret_path(conn, :new)
    assert html_response(conn, 200) =~ "Secret generieren"
  end

  test "try to create resource without current_user is logged in", %{conn: conn} do
    conn = post conn, secret_path(conn, :create), secret: @valid_attrs
    assert redirected_to(conn) == "/"
  end

  test "creates resource and redirects when data is valid and current_user is logged in", %{conn: conn} do
    user = create(:user)
    conn = assign(conn, :current_user, user)
    conn = post conn, secret_path(conn, :create), secret: @valid_attrs
    secret = Repo.get_by(Secret, @valid_attrs)
    assert secret
    assert redirected_to(conn) == secret_path(conn, :show, secret)
  end

  test "does not create resource and renders errors when data is invalid and current_user is logged in", %{conn: conn} do
    user = create(:user)
    conn = assign(conn, :current_user, user)
    conn = post conn, secret_path(conn, :create), secret: @invalid_attrs
    secret = Repo.get_by(Secret, @valid_attrs)
    assert secret
    assert redirected_to(conn) == secret_path(conn, :show, secret)
  end

  test "try to show chosen resource without current_user is logged in", %{conn: conn} do
    secret = create(:secret)
    conn = get conn, secret_path(conn, :show, secret)
    assert redirected_to(conn) == "/"
  end

  test "shows chosen resource with current_user is logged in", %{conn: conn} do
    user = create(:user)
    conn = assign(conn, :current_user, user)
    secret = create(:secret)
    conn = get conn, secret_path(conn, :show, secret)
    assert html_response(conn, 200) =~ "Secret"
  end

  test "renders page not found when id is nonexistent without current_user is logged in", %{conn: conn} do
    conn = get conn, secret_path(conn, :show, -1)
    assert redirected_to(conn) =~ "/"
  end

  test "renders page not found when id is nonexistent with current_user is logged in", %{conn: conn} do
    current_user = create(:user)
    conn = assign(conn, :current_user, current_user)

    assert_raise Ecto.NoResultsError, fn ->
      get conn, secret_path(conn, :show, -1)
    end
  end

  # test "renders form for editing chosen resource", %{conn: conn} do
  #   changeset = Secret.changeset(%Secret{}, @valid_attrs)
  #   secret = Repo.insert!(changeset)

  #   #secret = Repo.insert! %Secret{}
  #   conn = get conn, secret_path(conn, :edit, secret)
  #   assert html_response(conn, 200) =~ "Edit secret"
  # end

  # test "updates chosen resource and redirects when data is valid", %{conn: conn} do
  #   changeset = Secret.changeset(%Secret{}, @valid_attrs)
  #   secret = Repo.insert!(changeset)

  #   #secret = Repo.insert! %Secret{}
  #   conn = put conn, secret_path(conn, :update, secret), secret: @valid_attrs
  #   assert redirected_to(conn) == secret_path(conn, :show, secret)
  #   assert Repo.get_by(Secret, @valid_attrs)
  # end

  # test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
  #   changeset = Secret.changeset(%Secret{}, @valid_attrs)
  #   secret = Repo.insert!(changeset)

  #   #secret = Repo.insert! %Secret{}
  #   conn = put conn, secret_path(conn, :update, secret), secret: @invalid_attrs
  #   assert html_response(conn, 302) =~ "You are being" #"Edit secret"
  # end

  # test "deletes chosen resource", %{conn: conn} do
  #   changeset = Secret.changeset(%Secret{}, @valid_attrs)
  #   secret = Repo.insert!(changeset)

  #   #secret = Repo.insert! %Secret{}
  #   conn = delete conn, secret_path(conn, :delete, secret)
  #   assert redirected_to(conn) == secret_path(conn, :index)
  #   refute Repo.get(Secret, secret.id)
  # end
end
