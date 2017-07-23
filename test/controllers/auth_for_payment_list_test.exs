defmodule ClubHomepage.AuthForPaymentListTest do
  use ClubHomepage.Web.ConnCase

  import ClubHomepage.Factory

  alias ClubHomepage.Web.AuthForPaymentList, as: Auth

  setup do
    conn =
      build_conn()
      |> bypass_through(ClubHomepage.Web.Router, :browser)
      |> get("/")
    {:ok, %{conn: conn}}
  end

  test "authenticate_payment_list_owner_or_deputy halts when no current_user exists", %{conn: conn} do
    conn = Auth.authenticate_payment_list_owner_or_deputy(conn, [])
    assert conn.halted
    assert flash_messages_contain?(conn, "You need to be the owner or deputy of the payment list to view this side.")
  end

  test "authenticate_payment_list_owner_or_deputy halts when the current_user exists but is not owner or deputy of the payment_list", %{conn: conn} do
    user1 = insert(:user)
    conn = assign(conn, :current_user, user1)

    user2 = insert(:user)
    payment_list = insert(:payment_list, user_id: user2.id)
    conn = update_in(conn.params, fn (params) -> Map.put(params, "payment_list_id", payment_list.id) end)

    conn = Auth.authenticate_payment_list_owner_or_deputy(conn, payment_list_id_param_name: "payment_list_id")

    assert conn.halted
    assert flash_messages_contain?(conn, "You need to be the owner or deputy of the payment list to view this side.")
  end

  test "authenticate_payment_list_owner_or_deputy continues when the current_user exists but is not owner or deputy of the payment_list", %{conn: conn} do
    user = insert(:user)
    conn = assign(conn, :current_user, user)

    payment_list = insert(:payment_list, user_id: user.id)
    conn = update_in(conn.params, fn (params) -> Map.put(params, "payment_list_id", payment_list.id) end)

    conn = Auth.authenticate_payment_list_owner_or_deputy(conn, payment_list_id_param_name: "payment_list_id")

    refute conn.halted
  end
end
