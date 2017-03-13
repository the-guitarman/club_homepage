defmodule ClubHomepage.BeerListController do
  use ClubHomepage.Web, :controller

  alias ClubHomepage.BeerList

  def index(conn, _params) do
    beer_lists = Repo.all(BeerList)
    render(conn, "index.html", beer_lists: beer_lists)
  end

  def new(conn, _params) do
    changeset = BeerList.changeset(%BeerList{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"beer_list" => beer_list_params}) do
    changeset = BeerList.changeset(%BeerList{}, beer_list_params)

    case Repo.insert(changeset) do
      {:ok, _beer_list} ->
        conn
        |> put_flash(:info, "Beer list created successfully.")
        |> redirect(to: beer_list_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    beer_list = Repo.get!(BeerList, id)
    render(conn, "show.html", beer_list: beer_list)
  end

  def edit(conn, %{"id" => id}) do
    beer_list = Repo.get!(BeerList, id)
    changeset = BeerList.changeset(beer_list)
    render(conn, "edit.html", beer_list: beer_list, changeset: changeset)
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
        render(conn, "edit.html", beer_list: beer_list, changeset: changeset)
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
end
