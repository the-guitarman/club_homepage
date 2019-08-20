defmodule ClubHomepage.Web.AuthByRolePlugTest do
  use ClubHomepage.Web.ConnCase

  alias ClubHomepage.Web.UserRole
  alias ClubHomepage.Web.AuthByRole
  alias ClubHomepage.Web.AuthByRole.Helper, as: AuthByRoleHelper

  setup do
    conn =
      build_conn()
      |> bypass_through(ClubHomepage.Web.Router, :browser)
      |> get("/")
    {:ok, %{conn: conn}}
  end

  for user_role_key <- UserRole.defined_roles_keys() do
    function_name = AuthByRoleHelper.plug_function_name(user_role_key)

    test "#{function_name} halts when no current_user exists", %{conn: conn} do
      conn = AuthByRole.unquote(function_name)(conn, [])
      assert flash_messages_contain?(conn, "You are not authorized to view this page.")
      assert conn.halted
    end

    test "#{function_name} halts when current_user has no #{user_role_key} role", %{conn: conn} do
      conn =
        conn
        |> assign(:current_user, %ClubHomepage.User{roles: "unknown-role"})
        |> AuthByRole.unquote(function_name)([])
      assert flash_messages_contain?(conn, "You are not authorized to view this page.")
      assert conn.halted
    end

    test "#{function_name} continues when the current_user has the #{user_role_key} role", %{conn: conn} do
      conn =
        conn
        |> assign(:current_user, %ClubHomepage.User{roles: "#{unquote(user_role_key)}"})
        |> AuthByRole.unquote(function_name)([])
      refute conn.halted
    end
  end


end
