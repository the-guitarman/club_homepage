defmodule ClubHomepage.SessionController do
  use ClubHomepage.Web, :controller

  alias ClubHomepage.Auth

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
        |> put_flash(:info, "Du bist nun eingeloggt.")
        |> redirect(to: redirect_path(conn, redirect))
      {:error, :inactive, conn} ->
        conn
        |> put_flash(:error, "Dein Login/E-Mail-Adresse ist deaktiviert. Bitte kontaktiere den Webmaster.")
        |> render("new.html", redirect: redirect_path(conn, redirect))

      {:error, _reason, conn} ->
        conn
        |> put_flash(:error, "Dein Login/E-Mail-Adresse oder Dein Passwort sind ungültig. Bitte achte auf Groß- und Kleinschreibung.")
        |> render("new.html", redirect: redirect_path(conn, redirect))
    end
  end

  def delete(conn, _) do
    conn
    |> Auth.logout()
    |> put_flash(:info, "Du bist nun abgemeldet.")
    |> redirect(to: page_path(conn, :index))
  end

  defp redirect_path(conn, redirect) do
    case is_bitstring(redirect) do
      true  -> URI.decode(redirect)
      false -> page_path(conn, :index)
    end
  end
end
