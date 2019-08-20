defmodule ClubHomepage.Web.AuthByRole do
  @moduledoc """
  Provides plug methods to check wether the current logged in user has special user role.
  """

  import Phoenix.Controller
  import Plug.Conn
  import ClubHomepage.Web.Gettext

  alias ClubHomepage.Web.Router.Helpers
  alias ClubHomepage.Web.UserRole
  alias ClubHomepage.Web.AuthByRole.Helper, as: AuthByRoleHelper

  def init(_opts) do
    nil
  end

  def call(conn, _nil) do
    conn
  end

  for user_role_key <- UserRole.defined_roles_keys() do
    function_name = AuthByRoleHelper.plug_function_name(user_role_key)

    @doc """
    Returns the connection struct, if the current logged in user has the user role \"#{user_role_key}\". Otherwise halts the connection.
    """
    @spec unquote(function_name)(Plug.Conn.t, Keyword.t) :: Plug.Conn.t
    def unquote(function_name)(conn, _options) do
      has_role(conn, unquote(user_role_key))
    end
  end

  @doc """
  Returns the connection struct, if the current logged in user has one of the given user roles. Otherwise it halts the connection.
  """
  @spec has_role_from_list(Plug.Conn.t, Keyword.t) :: Plug.Conn.t
  def has_role_from_list(conn, options) do
    roles = Keyword.fetch!(options, :roles)
    case Enum.any?(roles, fn(role) -> UserRole.has_role?(conn, role) end) do
      true  -> conn
      false -> halt_request(conn)
    end
  end

  @doc """
  Returns true, if the current logged in user has the given user role or one of some given user roles. Otherwise false.
  """
  @spec has_role?(Plug.Conn.t, [String.t]) :: Boolean
  def has_role?(conn, roles) when is_list(roles) do
    Enum.any?(roles, fn(role) -> has_role?(conn, role) end)
  end

  @doc """
  Returns the connection struct, if the current logged in user has the given user role. Otherwise it halts the connection.
  """
  @spec has_role(Plug.Conn.t, String.t) :: Plug.Conn.t
  def has_role(conn, role) do
    if UserRole.has_role?(conn, role) || UserRole.has_role?(conn, "administrator") do
      conn
    else
      halt_request(conn)
    end
  end

  defp halt_request(conn) do
    conn
    |> put_flash(:error, gettext("error_auth_not_authorized"))
    |> redirect(to: Helpers.page_path(conn, :index))
    |> halt()
  end
end
