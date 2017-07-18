defmodule ClubHomepage.PaymentListDebitorControllerTest do
  use ClubHomepage.Web.ConnCase

  # alias ClubHomepage.PaymentList
  alias ClubHomepage.PaymentListDebitor

  import ClubHomepage.Factory

  import Ecto.Query, only: [from: 2]

  @valid_attrs %{payment_list_id: 1, user_id: 1, number_of_units: 2}
  @invalid_attrs %{payment_list_id: 0, user_id: 0, number_of_units: -1}

  setup context do
    conn = build_conn()
    user = insert(:user)
    payment_list = insert(:payment_list)
    debitor = insert(:payment_list_debitor)
    valid_attrs = %{@valid_attrs | payment_list_id: payment_list.id, user_id: debitor.user_id}
    if context[:login] do
      current_user = 
        if context[:user_roles] do
          insert(:user, roles: context[:user_roles])
        else
          insert(:user)
        end
      conn = assign(conn, :current_user, current_user)
      {:ok, conn: conn, current_user: current_user, valid_attrs: valid_attrs, payment_list: payment_list, debitor: debitor}
    else
      {:ok, conn: conn, valid_attrs: valid_attrs, payment_list: payment_list, debitor: debitor}
    end
  end

  @tag login: false
  test "requires user authentication on all actions", %{conn: conn, valid_attrs: valid_attrs} do
    payment_list = insert(:payment_list)
    debitor = insert(:payment_list_debitor)
    Enum.each([
      post(conn, payment_list_debitor_path(conn, :create, payment_list), payment_list_debitor: valid_attrs),
      get(conn, payment_list_debitor_path(conn, :edit, payment_list, debitor)),
      put(conn, payment_list_debitor_path(conn, :update, payment_list, debitor), payment_list_debitor: valid_attrs),
      delete(conn, payment_list_debitor_path(conn, :delete, payment_list, debitor))
    ], fn conn ->
      assert html_response(conn, 302)
      assert conn.halted
      assert redirected_to(conn) =~ "/"
    end)
  end

  @tag login: true
  test "creates resource and redirects when data is valid", %{conn: conn, valid_attrs: valid_attrs, payment_list: payment_list, debitor: debitor} do
    conn = post conn, payment_list_debitor_path(conn, :create, payment_list), payment_list_debitor: valid_attrs
    assert redirected_to(conn) == payment_list_path(conn, :show, payment_list)
    assert Repo.get_by(PaymentListDebitor, valid_attrs)
  end

  @tag login: true
  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    payment_list = insert(:payment_list)
    conn = post conn, payment_list_debitor_path(conn, :create, payment_list), payment_list_debitor: @invalid_attrs
    assert html_response(conn, 200) =~ "Create Payment List"
  end

  @tag login: true
  test "renders form for editing chosen resource", %{conn: conn} do
    payment_list = insert(:payment_list)
    debitor = insert(:payment_list_debitor, payment_list_id: payment_list.id)
    conn = get conn, payment_list_debitor_path(conn, :edit, payment_list, debitor)
    assert html_response(conn, 200) =~ "Edit Payment List"
  end

  @tag login: true
  test "updates chosen resource and redirects when data is valid", %{conn: conn, valid_attrs: valid_attrs} do
    payment_list = insert(:payment_list)
    debitor = insert(:payment_list_debitor, payment_list_id: payment_list.id)
    conn = put conn, payment_list_debitor_path(conn, :update, payment_list, debitor), payment_list_debitor: valid_attrs
    assert redirected_to(conn) == page_path(conn, :index)
    assert Repo.get_by(PaymentList, valid_attrs)
  end

  @tag login: true
  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    payment_list = insert(:payment_list)
    debitor = insert(:payment_list_debitor, payment_list_id: payment_list.id)
    conn = put conn, payment_list_debitor_path(conn, :update, payment_list, debitor), payment_list_debitor: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit Payment List"
  end

  @tag login: true
  test "deletes chosen resource", %{conn: conn} do
    payment_list = insert(:payment_list)
    debitor = insert(:payment_list_debitor, payment_list_id: payment_list.id)
    conn = delete conn, payment_list_debitor_path(conn, :delete, payment_list, debitor)
    assert redirected_to(conn) == payment_list_path(conn, :show, payment_list)
    refute Repo.get(PaymentListDebitor, debitor.id)
  end
end
