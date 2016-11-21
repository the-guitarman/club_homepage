defmodule ClubHomepage.Email do
  use Bamboo.Phoenix, view: ClubHomepage.EmailView

  def secret_text_email(email_address, secret) do
    domain = project_host
    user_registration_path = ClubHomepage.Router.Helpers.user_path(%Plug.Conn{}, :new, secret: secret)

    body = """
    Hi,

    here is your secret to register at #{domain}.

    Secret: #{secret}

    Register now: #{domain}/#{user_registration_path}

    Regards

    The Web-Team of #{domain}
    """

    new_email
    |> to(email_address)
    |> from("noreply@#{domain}")
    |> subject("Your Registration Secret")
    |> text_body(body)
  end

  def project_host do
    case project_domain_port do
      80 -> project_domain
      port -> "#{project_domain}:#{port}"
    end
  end

  def project_domain do
    case Application.get_env(:club_homepage, ClubHomepage.Endpoint)[:url][:host] do
      nil -> "localhost"
      "" -> "localhost"
      host -> host
    end
  end

  def project_domain_port do
    case Application.get_env(:club_homepage, ClubHomepage.Endpoint)[:http][:port] do
      nil -> 80
      "" -> 80
      port -> port
    end
  end
end
