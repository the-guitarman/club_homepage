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

  def project_host(conn) do
    case conn.port do
      80 -> conn.host
      port -> "#{conn.host}:#{port}"
    end
  end
end
