defmodule ClubHomepage.BeerListController do
  use ClubHomepage.Web, :controller

  alias ClubHomepage.BeerList

  plug :is_administrator?
  plug :scrub_params, "beer_list" when action in [:create, :update]
  plug :get_user_select_options when action in [:new, :create, :edit, :update]

  def index(conn, _params) do
    beer_lists = Repo.all(from(bl in BeerList, preload: [:user, :deputy]))
    render(conn, "index.html", beer_lists: beer_lists)
  end

  def new(conn, _params) do
    changeset = BeerList.changeset(%BeerList{})
    render(conn, "new.html", changeset: changeset,
           user_options: conn.assigns.user_options)
  end

  def create(conn, %{"beer_list" => beer_list_params}) do
    changeset = BeerList.changeset(%BeerList{}, beer_list_params)

    case Repo.insert(changeset) do
      {:ok, _beer_list} ->
        conn
        |> put_flash(:info, "Beer list created successfully.")
        |> redirect(to: beer_list_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset,
               user_options: conn.assigns.user_options)
    end
  end

  def show(conn, %{"id" => id}) do
    beer_list = Repo.get!(BeerList, id)
    render(conn, "show.html", beer_list: beer_list)
  end

  def edit(conn, %{"id" => id}) do
    beer_list = Repo.get!(BeerList, id)
    changeset = BeerList.changeset(beer_list)
    render(conn, "edit.html", beer_list: beer_list, changeset: changeset,
           user_options: conn.assigns.user_options)
  end

  def update(conn, %{"id" => id, "beer_list" => beer_list_params}) do
    beer_list = Repo.get!(BeerList, id)
    changeset = BeerList.changeset(beer_list, beer_list_params)

    case Repo.update(changeset) do
      {:ok, beer_list} ->
        conn
        |> put_flash(:info, "Beer list updated successfully.")
        |> redirect(to: beer_list_path(conn, :show, beer_list))
      {:error, changeset} ->
        render(conn, "edit.html", beer_list: beer_list, changeset: changeset,
               user_options: conn.assigns.user_options)
    end
  end

  def delete(conn, %{"id" => id}) do
    beer_list = Repo.get!(BeerList, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(beer_list)

    conn
    |> put_flash(:info, "Beer list deleted successfully.")
    |> redirect(to: beer_list_path(conn, :index))
  end

  defp get_user_select_options(conn, _) do
    query = from(s in ClubHomepage.User,
                 select: {s.name, s.id},
                 order_by: [desc: s.name])
    assign(conn, :user_options, Repo.all(query))
  end
end
