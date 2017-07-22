defmodule ClubHomepage.Web.AuthForPaymentList do
  import Phoenix.Controller
  import Plug.Conn

  alias ClubHomepage.Web.Router.Helpers
  alias ClubHomepage.Repo

  # def init(opts) do
  #   opts
  # end

  # def call(conn, opts) do
  #   conn
  # end

  def authenticate_payment_list_owner_or_deputy(conn, options) do
    case conn.assigns[:current_user] do
      nil -> conn_halt(conn)
      current_user ->
        payment_list = get_payment_list(conn, Keyword.fetch!(options, :payment_list_id_param_name))
        cond do
          current_user.id == payment_list.user_id || current_user.id == payment_list.deputy_id -> conn
          true -> conn_halt(conn)
        end
    end
  end

  defp conn_halt(conn) do
    #"Du musst Verantwortlicher oder Vertreter für diese Bezahlliste sein, um diese Seite sehen zu können."
    conn
    |> put_flash(:error, Gettext.gettext(ClubHomepage.Web.Gettext, :error_auth_for_payment_list)
    |> redirect(to: Helpers.session_path(conn, :new, redirect: URI.encode(conn.request_path)))
    |> halt()
  end

  defp get_payment_list(conn, param_name) do
    Repo.get!(PaymentList, conn.params[param_name])
    #|> Repo.preload([:user, :deputy, :debitors])
  end
end
