defmodule ClubHomepage.Web.PaymentListController do
  use ClubHomepage.Web, :controller

  alias ClubHomepage.PaymentList
  alias ClubHomepage.PaymentListDebitor

  plug :authenticate_user 
  plug :is_administrator? when action in [:index]
  plug :authenticate_payment_list_owner_or_deputy, [payment_list_id_param_name: "id"] when not action in [:index, :new, :create]
  plug :scrub_params, "payment_list" when action in [:create, :update]
  plug :get_user_select_options when action in [:new, :create, :edit, :update, :show]
  plug :get_deputy_select_options when action in [:new, :create, :edit, :update]

  def index(conn, _params) do
    payment_lists = Repo.all(from(bl in PaymentList, preload: [:user, :deputy]))
    render(conn, "index.html", payment_lists: payment_lists)
  end

  def new(conn, _params) do
    changeset = PaymentList.changeset(%PaymentList{user_id: current_user(conn).id})
    render(conn, "new.html", changeset: changeset,
           user_options: conn.assigns.user_options,
           deputy_options: conn.assigns.deputy_options,
           form_mode: :new)
  end

  def create(conn, %{"payment_list" => payment_list_params}) do
    payment_list_params = Map.put(payment_list_params, "user_id", current_user(conn).id)
    changeset = PaymentList.changeset(%PaymentList{}, payment_list_params)

    case Repo.insert(changeset) do
      {:ok, _payment_list} ->
        conn
        |> put_flash(:info, gettext("payment_list_created_successfully"))
        |> redirect(to: page_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset,
               user_options: conn.assigns.user_options,
               deputy_options: conn.assigns.deputy_options,
               form_mode: :new)
    end
  end

  def show(conn, %{"id" => id}) do
    changeset = PaymentListDebitor.changeset(%PaymentListDebitor{payment_list_id: id, number_of_units: 1})
    payment_list = Repo.one!(from(pl in PaymentList, preload: [:user, :deputy, :debitors], where: pl.id == ^id))
    render(conn, "show.html", payment_list: payment_list, changeset: changeset, user_options: get_possible_debitors(payment_list))
  end

  def edit(conn, %{"id" => id}) do
    payment_list = Repo.get!(PaymentList, id)
    changeset = PaymentList.changeset(payment_list)
    render(conn, "edit.html", payment_list: payment_list, changeset: changeset,
           user_options: conn.assigns.user_options,
           deputy_options: conn.assigns.deputy_options,
           form_mode: :edit)
  end

  def update(conn, %{"id" => id, "payment_list" => payment_list_params}) do
    payment_list = Repo.get!(PaymentList, id)
    changeset = PaymentList.changeset(payment_list, payment_list_params)

    case Repo.update(changeset) do
      {:ok, _payment_list} ->
        conn
        |> put_flash(:info, gettext("payment_list_updated_successfully"))
        |> redirect(to: page_path(conn, :index))
      {:error, changeset} ->
        render(conn, "edit.html", payment_list: payment_list, changeset: changeset,
               user_options: conn.assigns.user_options,
               deputy_options: conn.assigns.deputy_options,
               form_mode: :edit)
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

  defp get_possible_debitors(payment_list) do
    debitor_ids = Enum.map(payment_list.debitors, fn(debitor) -> debitor.user_id end)
    from(u in ClubHomepage.User, select: {u.name, u.id}, where: not u.id in ^debitor_ids, order_by: [desc: u.name])
    |> Repo.all
  end
end
