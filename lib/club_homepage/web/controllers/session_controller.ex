defmodule ClubHomepage.Web.SessionController do
  use ClubHomepage.Web, :controller

  alias ClubHomepage.Web.Auth

  plug :require_no_user when action in [:new, :create]
  plug :authenticate_user when action in [:delete]

  def new(conn, %{"redirect" => redirect}) do
    render conn, "new.html", redirect: redirect_path(conn, redirect)
  end
  def new(conn, _) do
    render conn, "new.html", redirect: redirect_path(conn, nil)
  end

  def create(conn, %{"session" => %{"login" => login_or_email, "password" => pass, "redirect" => redirect}}) do
    case Auth.login_by_login_or_email_and_pass(conn, login_or_email, pass, repo: Repo) do
      {:ok, conn} ->
        conn
        |> put_flash(:info, gettext("logged_in_now"))
        |> redirect(to: redirect_path(conn, redirect))
      {:error, :inactive, conn} ->
        conn
        |> put_flash(:error, gettext("account_inactive"))
        |> render("new.html", redirect: redirect_path(conn, redirect))

      {:error, _reason, conn} ->
        conn
        |> put_flash(:error, gettext("credentials_wrong"))
        |> render("new.html", redirect: redirect_path(conn, redirect))
    end
  end

  def delete(conn, _) do
    conn
    |> Auth.logout()
    |> put_flash(:info, gettext("logged_out_now"))
    |> redirect(to: page_path(conn, :index))
  end

  defp redirect_path(conn, redirect) do
    case is_bitstring(redirect) do
      true  -> URI.decode(redirect)
      false -> page_path(conn, :index)
    end
  end
end
