defmodule ClubHomepageWeb.Auth do
  @moduledoc """
  Provides the central authentication system.
  """

  import Phoenix.Controller
  import Plug.Conn
  import Comeonin.Bcrypt, only: [checkpw: 2]
  import ClubHomepageWeb.Gettext

  alias ClubHomepageWeb.Router.Helpers
  alias ClubHomepage.User

  def init(opts) do
    Keyword.fetch!(opts, :repo)
  end

  def call(conn, repo) do
    user_id = get_session(conn, :user_id)
    cond do
      user = conn.assigns[:current_user] ->
        put_current_user(conn, user)
      user = user_id && repo.get(User, user_id) ->
        put_current_user(conn, user)
      true ->
        assign(conn, :current_user, nil)
    end
  end

  @doc """
  Returns the current user of the given connection struct.
  """
  @spec current_user(Plug.Conn.t) :: User | Nil
  def current_user(conn) do
    conn.assigns[:current_user]
  end

  @doc """
  Returns the current user id of the given connection struct or an empty string.
  """
  @spec current_user_id(Plug.Conn.t) :: Integer.t | String.t
  def current_user_id(conn) do
    case logged_in?(conn) do
      false -> ""
      true -> current_user(conn).id
    end
  end

  @doc """
  Returns wether a user is logged in or not.
  """
  @spec logged_in?(Plug.Conn.t) :: Boolean
  def logged_in?(conn), do: logged_in?(conn, %{})
  def logged_in?(conn, _options) do
    !!conn.assigns.current_user
  end

  @doc """
  Returns wether a user is logged out or not.
  """
  @spec logged_out?(Plug.Conn.t) :: Boolean
  def logged_out?(conn), do: logged_out?(conn, %{})
  def logged_out?(conn, options) do
    !logged_in?(conn, options)
  end

  @doc """
  Plug method to ensure, that a user is logged in. Otherwise it halts the connection.
  """
  @spec authenticate_user(Plug.Conn.t, Keyword.t) :: Plug.Conn.t
  def authenticate_user(conn, _options) do
    if conn.assigns[:current_user] do
      conn
    else
      conn
      |> put_flash(:error, gettext("error_auth_login_needed"))
      |> redirect(to: Helpers.session_path(conn, :new, redirect: URI.encode(conn.request_path)))
      |> halt()
    end
  end

  @doc """
  Plug method to ensure, that no user is logged in. Otherwise it halts the connection.
  """
  @spec require_no_user(Plug.Conn.t, Keyword.t) :: Plug.Conn.t
  def require_no_user(conn, _options) do
    if conn.assigns[:current_user] do
      conn
      |> put_flash(:error, gettext("error_auth_logout_needed"))
      |> redirect(to: Helpers.page_path(conn, :index))
      |> halt()
    else
      conn
    end
  end

  @doc """
  Logs in the given user struct and renews the current session.
  """
  @spec login(Plug.Conn.t, User) :: Plug.Conn.t
  def login(conn, user) do
    conn
    |> assign(:current_user, user)
    |> put_session(:user_id, user.id)
    |> configure_session(renew: true)
  end

  defp put_current_user(conn, user) do
    token = Phoenix.Token.sign(conn, "user socket", user.id)

    conn
    |> assign(:current_user, user)
    |> assign(:user_token, token)
  end

  @doc """
  Trys to find a user to login by login or email and returns an :ok tuple. Otherwise returns an :error tuple.
  """
  @spec login_by_login_or_email_and_pass(Plug.Conn.t, String.t, String.t, Keyword.t) :: Tuple.t
  def login_by_login_or_email_and_pass(conn, login_or_email, given_pass, opts) do
    user = find_user(login_or_email, opts)
    cond do
      user && user.active == false ->
        {:error, :inactive, conn}
      user && user.password_hash && checkpw(given_pass, user.password_hash) ->
        {:ok, login(conn, user)}
      user ->
        {:error, :unauthorized, conn}
      true ->
        {:error, :not_found, conn}
    end
  end

  @doc """
  Logs out the current user and renews the current session.
  """
  @spec logout(Plug.Conn.t) :: Plug.Conn.t
  def logout(conn) do
    #delete_session(conn, :user_id)
    configure_session(conn, drop: true)
  end

  defp find_user(login_or_email, opts) do
    repo = Keyword.fetch!(opts, :repo)
    case String.match?(login_or_email, ~r/\w@\w/) do
      true -> repo.get_by(User, email: login_or_email)
      false -> repo.get_by(User, login: login_or_email)
    end
  end
end
