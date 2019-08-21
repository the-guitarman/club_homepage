defmodule ClubHomepageWeb.PaymentListDebitorController do
  use ClubHomepageWeb, :controller

  alias ClubHomepage.PaymentList
  alias ClubHomepage.PaymentListDebitor
  alias ClubHomepageWeb.PaymentListDebitorHistoryRecordCreator, as: HistoryRecordCreator

  plug :authenticate_user
  plug :current_user_is_payment_list_debitor when action in [:show]
  plug :authenticate_payment_list_owner_or_deputy, [payment_list_id_param_name: "payment_list_id"] when action not in [:show]
  plug :scrub_params, "payment_list_debitor" when action in [:create, :update]
  plug :get_user_select_options when action in [:create, :edit, :update]
  plug :get_deputy_select_options when action in [:create, :edit, :update]

  def create(conn, %{"payment_list_debitor" => payment_list_debitor_params}) do
    payment_list =
      conn
      |> get_payment_list()
      |> Repo.preload([:user, :deputy, :debitors])

    changeset = PaymentListDebitor.changeset(%PaymentListDebitor{payment_list_id: payment_list.id}, payment_list_debitor_params)

    case Repo.insert(changeset) do
      {:ok, payment_list_debitor} ->
        HistoryRecordCreator.run(payment_list_debitor, current_user(conn))
        conn
        |> put_flash(:info, gettext("payment_list_debitor_created_successfully"))
        |> redirect(to: Routes.payment_list_path(conn, :show, payment_list))
      {:error, changeset} ->
        {:safe, body} = Phoenix.View.render(ClubHomepageWeb.PaymentListView, "show.html", changeset: changeset,
               conn: conn,
               payment_list: payment_list, 
               user_options: conn.assigns.user_options)
        conn
        |> put_resp_content_type("text/html")
        |> send_resp(200, body)
    end
  end

  def show(conn, %{"payment_list_id" => payment_list_id, "id" => id}) do
    payment_list = Repo.get!(PaymentList, payment_list_id)
    debitor =
      Repo.get!(PaymentListDebitor, id)
      |> Repo.preload([:user, :history_records])
    history_records =
      debitor.history_records
      |> Enum.map(fn(hr) -> Repo.preload(hr, [:editor]) end)
    render(conn, "show.html", payment_list: payment_list, debitor: debitor, history_records: history_records)
  end

  def edit(conn, %{"payment_list_id" => payment_list_id, "id" => id}) do
    payment_list = Repo.get!(PaymentList, payment_list_id)
    debitor = Repo.get!(PaymentListDebitor, id)
    changeset = PaymentListDebitor.changeset(debitor)
    render(conn, "edit.html", payment_list: payment_list, debitor: debitor, changeset: changeset, user_options: conn.assigns.user_options, form_mode: :edit)
  end

  def update(conn, %{"payment_list_id" => payment_list_id, "id" => id, "payment_list_debitor" => payment_list_debitor_params}) do
    payment_list =
      Repo.get!(PaymentList, payment_list_id)
      |> Repo.preload([:user, :deputy, :debitors])
    debitor = Repo.get!(PaymentListDebitor, id)
    changeset = PaymentListDebitor.changeset(debitor, payment_list_debitor_params)

    case Repo.update(changeset) do
      {:ok, payment_list_debitor} ->
        HistoryRecordCreator.run(debitor, payment_list_debitor, current_user(conn))
        conn
        |> put_flash(:info, gettext("payment_list_updated_successfully"))
        |> redirect(to: Routes.payment_list_path(conn, :show, payment_list))
      {:error, changeset} ->
        render(conn, "edit.html", payment_list: payment_list, debitor: debitor, changeset: changeset, user_options: conn.assigns.user_options, form_mode: :edit)
    end
  end

  def delete(conn, %{"payment_list_id" => payment_list_id, "id" => id}) do
    payment_list = Repo.get!(PaymentList, payment_list_id)
    debitor = Repo.get!(PaymentListDebitor, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(debitor)

    conn
    |> put_flash(:info, gettext("payment_list_debitor_deleted_successfully"))
    |> redirect(to: Routes.payment_list_path(conn, :show, payment_list))
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

  defp current_user_is_payment_list_debitor(conn, _options) do
    debitor =
      Repo.get!(PaymentListDebitor, conn.params["id"])
      |> Repo.preload([:user])
    cond do
      debitor.user == conn.assigns[:current_user] -> conn
      true -> 
        conn
        |> put_flash(:error, gettext("error_auth_not_authorized"))
        |> redirect(to: Routes.page_path(conn, :index))
        |> halt()
      end
  end
end
