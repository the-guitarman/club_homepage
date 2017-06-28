defmodule ClubHomepage.PaymentListControllerTest do
  use ClubHomepage.Web.ConnCase

  alias ClubHomepage.PaymentList

  import ClubHomepage.Factory

  import Ecto.Query, only: [from: 2]

  @valid_attrs %{title: "Team 1", user_id: 1, price_per_piece: 1.5}
  @invalid_attrs %{title: "", price_per_piece: nil}

  setup context do
    conn = build_conn()
    user = insert(:user)
    valid_attrs = %{@valid_attrs | user_id: user.id}
    if context[:login] do
      current_user = 
        if context[:user_roles] do
          insert(:user, roles: context[:user_roles])
        else
          insert(:user)
        end
      conn = assign(conn, :current_user, current_user)
      {:ok, conn: conn, current_user: current_user, valid_attrs: valid_attrs}
    else
      {:ok, conn: conn, valid_attrs: valid_attrs}
    end
  end

  @tag login: false
  test "requires user authentication on all actions", %{conn: conn, valid_attrs: valid_attrs} do
    payment_list = insert(:payment_list)
    Enum.each([
      get(conn, payment_list_path(conn, :index)),
      get(conn, payment_list_path(conn, :show, payment_list)),
      get(conn, payment_list_path(conn, :new)),
      post(conn, payment_list_path(conn, :create), payment_list: valid_attrs),
      get(conn, payment_list_path(conn, :edit, payment_list)),
      put(conn, payment_list_path(conn, :update, payment_list), payment_list: valid_attrs),
      delete(conn, payment_list_path(conn, :delete, payment_list))
    ], fn conn ->
      assert html_response(conn, 302)
      assert conn.halted
      assert redirected_to(conn) =~ "/"
    end)
  end

  @tag login: true
  test "lists all entries on index", %{conn: conn} do
    conn = get conn, payment_list_path(conn, :index)
    assert html_response(conn, 200) =~ "All Payment Lists"
  end

  @tag login: true
  test "renders form for new resources", %{conn: conn} do
    conn = get conn, payment_list_path(conn, :new)
    assert html_response(conn, 200) =~ "Create Payment List"
  end

  @tag login: true
  test "creates resource and redirects when data is valid", %{conn: conn, valid_attrs: valid_attrs} do
    conn = post conn, payment_list_path(conn, :create), payment_list: valid_attrs
    assert redirected_to(conn) == page_path(conn, :index)
    assert Repo.get_by(PaymentList, %{title: valid_attrs[:title]})
  end

  @tag login: true
  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, payment_list_path(conn, :create), payment_list: @invalid_attrs
    assert html_response(conn, 200) =~ "Create Payment List"
  end

  @tag login: true
  test "shows chosen resource", %{conn: conn} do
    payment_list = insert(:payment_list)
    conn = get conn, payment_list_path(conn, :show, payment_list)
    assert html_response(conn, 200) =~ "Payment List - #{payment_list.title}"
  end

  @tag login: true
  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, payment_list_path(conn, :show, -1)
    end
  end

  @tag login: true
  test "renders form for editing chosen resource", %{conn: conn} do
    payment_list = Repo.insert! %PaymentList{}
    conn = get conn, payment_list_path(conn, :edit, payment_list)
    assert html_response(conn, 200) =~ "Edit Payment List"
  end

  @tag login: true
  test "updates chosen resource and redirects when data is valid", %{conn: conn, valid_attrs: valid_attrs} do
    payment_list = Repo.insert! %PaymentList{}
    conn = put conn, payment_list_path(conn, :update, payment_list), payment_list: valid_attrs
    assert redirected_to(conn) == page_path(conn, :index)
    assert Repo.get_by(PaymentList, valid_attrs)
  end

  @tag login: true
  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    payment_list = Repo.insert! %PaymentList{}
    conn = put conn, payment_list_path(conn, :update, payment_list), payment_list: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit Payment List"
  end

  @tag login: true
  test "deletes chosen resource", %{conn: conn} do
    payment_list = Repo.insert! %PaymentList{}
    conn = delete conn, payment_list_path(conn, :delete, payment_list)
    assert redirected_to(conn) == payment_list_path(conn, :index)
    refute Repo.get(PaymentList, payment_list.id)
  end
end
