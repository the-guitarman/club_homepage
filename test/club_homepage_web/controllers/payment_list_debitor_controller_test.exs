defmodule ClubHomepage.PaymentListDebitorControllerTest do
  use ClubHomepageWeb.ConnCase

  # alias ClubHomepage.PaymentList
  alias ClubHomepage.PaymentListDebitor

  import ClubHomepage.Factory

  @valid_attrs %{payment_list_id: 1, user_id: 1, number_of_units: 2}
  @invalid_attrs %{payment_list_id: 0, user_id: 0, number_of_units: -1}

  setup context do
    conn = build_conn()
    user = 
      if context[:user_roles] do
        insert(:user, roles: context[:user_roles])
      else
        insert(:user)
      end
    payment_list = insert(:payment_list, user_id: user.id)
    debitor = insert(:payment_list_debitor)
    valid_attrs = %{@valid_attrs | payment_list_id: payment_list.id, user_id: debitor.user_id}
    if context[:login] do
      conn = assign(conn, :current_user, user)
      {:ok, conn: conn, current_user: user, valid_attrs: valid_attrs, payment_list: payment_list, debitor: debitor}
    else
      {:ok, conn: conn, valid_attrs: valid_attrs, payment_list: payment_list, debitor: debitor}
    end
  end

  @tag login: false
  test "requires user authentication on all actions", %{conn: conn, valid_attrs: valid_attrs} do
    payment_list = insert(:payment_list)
    debitor = insert(:payment_list_debitor)
    Enum.each([
      get(conn, payment_list_debitor_path(conn, :show, payment_list, debitor)),
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
  test "try to show payment list debitor details of another user", %{conn: conn} do
    payment_list = insert(:payment_list)
    debitor =
      insert(:payment_list_debitor, payment_list_id: payment_list.id)
      |> Repo.preload([:user])
    conn = get conn, payment_list_debitor_path(conn, :show, payment_list, debitor)
    assert html_response(conn, 302)
    assert conn.halted
    assert redirected_to(conn) =~ "/"
  end

  @tag login: true
  test "show payment list debitor details if the current logged in user", %{conn: conn} do
    current_user = conn.assigns[:current_user]
    payment_list = insert(:payment_list)
    debitor =
      insert(:payment_list_debitor, payment_list_id: payment_list.id, user_id: current_user.id)
      |> Repo.preload([:user])
    conn = get conn, payment_list_debitor_path(conn, :show, payment_list, debitor)
    assert html_response(conn, 200) =~ "<h2>Details - #{debitor.user.name}</h2>"
  end

  @tag login: true
  test "creates resource and redirects when data is valid", %{conn: conn, valid_attrs: valid_attrs, payment_list: payment_list, debitor: _debitor} do
    conn = post conn, payment_list_debitor_path(conn, :create, payment_list), payment_list_debitor: valid_attrs
    assert redirected_to(conn) == payment_list_path(conn, :show, payment_list)
    assert Repo.get_by(PaymentListDebitor, valid_attrs)
  end

  @tag login: true
  test "does not create resource and renders errors when data is invalid", %{conn: conn, payment_list: payment_list} do
    conn = post conn, payment_list_debitor_path(conn, :create, payment_list), payment_list_debitor: @invalid_attrs
    assert html_response(conn, 200) =~ "<h2>Payment List - #{payment_list.title}</h2>"
  end

  @tag login: true
  test "renders form for editing chosen resource", %{conn: conn, payment_list: payment_list} do
    debitor = insert(:payment_list_debitor, payment_list_id: payment_list.id)
    conn = get conn, payment_list_debitor_path(conn, :edit, payment_list, debitor)
    assert html_response(conn, 200) =~ "Edit Payment List Debitor"
  end

  @tag login: true
  test "updates chosen resource and redirects when data is valid", %{conn: conn, valid_attrs: valid_attrs, payment_list: payment_list} do
    debitor = insert(:payment_list_debitor, payment_list_id: payment_list.id)
    conn = put conn, payment_list_debitor_path(conn, :update, payment_list, debitor), payment_list_debitor: valid_attrs
    assert redirected_to(conn) == payment_list_path(conn, :show, payment_list)
    assert Repo.get_by(PaymentListDebitor, valid_attrs)
  end

  @tag login: true
  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn, payment_list: payment_list} do
    debitor = insert(:payment_list_debitor, payment_list_id: payment_list.id)
    conn = put conn, payment_list_debitor_path(conn, :update, payment_list, debitor), payment_list_debitor: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit Payment List Debitor"
  end

  @tag login: true
  test "deletes chosen resource", %{conn: conn, payment_list: payment_list} do
    debitor = insert(:payment_list_debitor, payment_list_id: payment_list.id)
    conn = delete conn, payment_list_debitor_path(conn, :delete, payment_list, debitor)
    assert redirected_to(conn) == payment_list_path(conn, :show, payment_list)
    refute Repo.get(PaymentListDebitor, debitor.id)
  end
end
