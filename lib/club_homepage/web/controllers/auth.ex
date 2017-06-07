defmodule ClubHomepage.Auth do
  import Phoenix.Controller
  import Plug.Conn
  import Comeonin.Bcrypt, only: [checkpw: 2]

  alias ClubHomepage.Router.Helpers
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

  def current_user(conn) do
    conn.assigns[:current_user]
  end

  def logged_in?(conn), do: logged_in?(conn, %{})
  def logged_in?(conn, _options) do
    !!conn.assigns.current_user
  end

  def logged_out?(conn), do: logged_out?(conn, %{})
  def logged_out?(conn, options) do
    !logged_in?(conn, options)
  end

  def authenticate_user(conn, _options) do
    if conn.assigns[:current_user] do
      conn
    else
      conn
      |> put_flash(:error, "Du musst eingeloggt sein, um diese Seite sehen zu können.")
      |> redirect(to: Helpers.session_path(conn, :new, redirect: URI.encode(conn.request_path)))
      |> halt()
    end
  end

  def require_no_user(conn, _options) do
    if conn.assigns[:current_user] do
      conn
      |> put_flash(:error, "Du musst ausgeloggt sein, um diese Seite sehen zu können.")
      |> redirect(to: Helpers.page_path(conn, :index))
      |> halt()
    else
      conn
    end
  end

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

  def logout(conn) do
    #delete_session(conn, :user_id)
    configure_session(conn, drop: true)
  end

  defp find_user(login_or_email, opts) do
    repo = Keyword.fetch!(opts, :repo)
    case String.match?(login_or_email, ~r/@/) do
      true -> repo.get_by(User, email: login_or_email)
      false -> repo.get_by(User, login: login_or_email)
    end
  end
end
