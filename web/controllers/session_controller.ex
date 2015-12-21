defmodule ClubHomepage.SessionController do
  use ClubHomepage.Web, :controller

  alias ClubHomepage.Auth

  def new(conn, _) do
    render conn, "new.html"
  end

  def create(conn, %{"session" => %{"login" => login_or_email, "password" => pass}}) do
    case Auth.login_by_login_or_email_and_pass(conn, login_or_email, pass, repo: Repo) do
      {:ok, conn} ->
        conn
        |> put_flash(:info, "Du bist nun eingeloggt.")
        |> redirect(to: page_path(conn, :index))
      {:error, _reason, conn} ->
        conn
        |> put_flash(:error, "Dein Login/E-Mail Adresse oder Dein Passwort sind ungültig. Bitte achte auf Groß- und Kleinschreibung.")
        |> render("new.html")
    end
  end

  def delete(conn, _) do
    conn
    |> Auth.logout()
    |> put_flash(:info, "Du bist nun abgemeldet.")
    |> redirect(to: page_path(conn, :index))
  end
end