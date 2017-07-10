defmodule ClubHomepage.Web.PaymentListDebitorController do
  use ClubHomepage.Web, :controller

  alias ClubHomepage.PaymentList
  alias ClubHomepage.PaymentListDebitor

  plug :authenticate_user 
  plug :scrub_params, "payment_list_debitor" when action in [:create, :update]
  plug :get_user_select_options when action in [:create, :edit, :update]
  plug :get_deputy_select_options when action in [:create, :edit, :update]

  def create(conn, %{"payment_list_debitor" => payment_list_debitor_params}) do
    payment_list = get_payment_list(conn)


    changeset = PaymentListDebitor.changeset(%PaymentListDebitor{payment_list_id: payment_list.id}, payment_list_debitor_params)

    case Repo.insert(changeset) do
      {:ok, _payment_list_debitor} ->
        conn
        |> put_flash(:info, gettext("payment_list_debitor_created_successfully"))
        |> redirect(to: payment_list_path(conn, :show, payment_list))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset,
               user_options: conn.assigns.user_options,
               deputy_options: conn.assigns.deputy_options,
               form_mode: :new)
    end
  end

  def delete(conn, %{"id" => id}) do
    payment_list = Repo.get!(PaymentList, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(payment_list)

    conn
    |> put_flash(:info, gettext("payment_list_deleted_successfully"))
    |> redirect(to: payment_list_path(conn, :index))
  end

  defp get_users do
    from(s in ClubHomepage.User, select: {s.name, s.id}, order_by: [desc: s.name])
    |> Repo.all
  end

  defp get_user_select_options(conn, _) do
    assign(conn, :user_options, get_users())
  end

  defp get_deputy_select_options(conn, _) do
    deputy_options = Enum.filter(get_users(), fn({_user_name, user_id}) -> current_user(conn).id != user_id end)
    assign(conn, :deputy_options, deputy_options)
  end

  defp get_payment_list(conn) do
    Repo.get!(PaymentList, conn.params["payment_list_id"])
  end
end
