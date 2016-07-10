defmodule ClubHomepage.AddressControllerTest do
  use ClubHomepage.ConnCase

  alias ClubHomepage.Address

  import ClubHomepage.Factory

  @valid_attrs %{city: "some content", street: "some content", zip_code: "01234"}
  @invalid_attrs %{}

  setup context do
    conn = build_conn()
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
    address = create(:address)
    Enum.each([
      get(conn, address_path(conn, :index)),
      get(conn, address_path(conn, :new)),
      post(conn, address_path(conn, :create), address: @valid_attrs),
      get(conn, address_path(conn, :edit, address)),
      put(conn, address_path(conn, :update, address), address: @valid_attrs),
      delete(conn, address_path(conn, :delete, address))
    ], fn conn ->
      assert html_response(conn, 302)
      assert conn.halted
      assert redirected_to(conn) =~ "/"
    end)
  end

  @tag login: true
  test "lists all entries on index", %{conn: conn, current_user: _current_user} do
    conn = get conn, address_path(conn, :index)
    assert html_response(conn, 200) =~ "All Addresses"
  end

  @tag login: true
  test "renders form for new resources", %{conn: conn, current_user: _current_user} do
    conn = get conn, address_path(conn, :new)
    assert html_response(conn, 200) =~ "Create Address"
  end

  @tag login: true
  test "creates resource and redirects when data is valid", %{conn: conn, current_user: _current_user} do
    conn = post conn, address_path(conn, :create), address: @valid_attrs
    assert redirected_to(conn) == address_path(conn, :index) <> "#address-#{get_highest_id(Address)}"
    assert Repo.get_by(Address, @valid_attrs)
    assert get_flash(conn, :info) == "Address created successfully."
  end

  @tag login: true
  test "does not create resource and renders errors when data is invalid", %{conn: conn, current_user: _current_user} do
    conn = post conn, address_path(conn, :create), address: @invalid_attrs
    assert html_response(conn, 200) =~ "Create Address"
  end

  @tag login: true
  test "renders form for editing chosen resource", %{conn: conn, current_user: _current_user} do
    address = Repo.insert! %Address{}
    conn = get conn, address_path(conn, :edit, address)
    assert html_response(conn, 200) =~ "Edit Address"
  end

  @tag login: true
  test "updates chosen resource and redirects when data is valid", %{conn: conn, current_user: _current_user} do
    address = Repo.insert! %Address{}
    conn = put conn, address_path(conn, :update, address), address: @valid_attrs
    assert redirected_to(conn) == address_path(conn, :index) <> "#address-#{address.id}"
    assert Repo.get_by(Address, @valid_attrs)
  end

  @tag login: true
  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn, current_user: _current_user} do
    address = Repo.insert! %Address{}
    conn = put conn, address_path(conn, :update, address), address: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit Address"
  end

  @tag login: true
  test "deletes chosen resource", %{conn: conn, current_user: _current_user} do
    address = Repo.insert! %Address{}
    conn = delete conn, address_path(conn, :delete, address)
    assert redirected_to(conn) == address_path(conn, :index)
    refute Repo.get(Address, address.id)
  end
end
