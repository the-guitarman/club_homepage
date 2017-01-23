defmodule ClubHomepage.Email do
  use Bamboo.Phoenix, view: ClubHomepage.EmailView

  import ClubHomepage.Gettext

  def secret_text_email(conn, secret) do
    domain = project_host(conn)
    user_registration_path = ClubHomepage.Router.Helpers.user_path(%Plug.Conn{}, :new, secret: secret.key)

    body = gettext("secret_email_text", domain: domain, secret: secret.key, scheme: conn.scheme, user_registration_path: user_registration_path)

    new_email
    |> to(secret.email)
    |> from("noreply@#{domain}")
    |> subject(gettext("secret_email_subject"))
    |> text_body(body)
  end

  def forgot_password_email(conn, user) do
    domain = project_host(conn)
    change_password_path = ClubHomepage.Router.Helpers.change_password_path(%Plug.Conn{}, :change_password, id: user.id, token: user.token)

    body = gettext("forgot_password_email_text", domain: domain, scheme: conn.scheme, change_password_path: change_password_path)

    new_email
    |> to(user.email)
    |> from("noreply@#{domain}")
    |> subject(gettext("forgot_password_email_subject"))
    |> text_body(body)
  end

  defp project_host(conn) do
    case conn.port do
      80 -> conn.host
      port -> "#{conn.host}:#{port}"
    end
  end
end
