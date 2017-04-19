defmodule ClubHomepage.BeerListDrinkerController do
  use ClubHomepage.Web, :controller

  alias ClubHomepage.BeerListDrinker

  plug :is_administrator?
  plug :scrub_params, "beer_list_drinker" when action in [:create, :update]

  def index(conn, _params) do
    beer_list_drinkers = Repo.all(BeerListDrinker)
    render(conn, "index.html", beer_list_drinkers: beer_list_drinkers)
  end

  def new(conn, _params) do
    changeset = BeerListDrinker.changeset(%BeerListDrinker{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"beer_list_drinker" => beer_list_drinker_params}) do
    changeset = BeerListDrinker.changeset(%BeerListDrinker{}, beer_list_drinker_params)

    case Repo.insert(changeset) do
      {:ok, _beer_list_drinker} ->
        conn
        |> put_flash(:info, "Beer list drinker created successfully.")
        |> redirect(to: page_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    beer_list_drinker = Repo.get!(BeerListDrinker, id)
    render(conn, "show.html", beer_list_drinker: beer_list_drinker)
  end

  def edit(conn, %{"id" => id}) do
    beer_list_drinker = Repo.get!(BeerListDrinker, id)
    changeset = BeerListDrinker.changeset(beer_list_drinker)
    render(conn, "edit.html", beer_list_drinker: beer_list_drinker, changeset: changeset)
  end

  def update(conn, %{"id" => id, "beer_list_drinker" => beer_list_drinker_params}) do
    beer_list_drinker = Repo.get!(BeerListDrinker, id)
    changeset = BeerListDrinker.changeset(beer_list_drinker, beer_list_drinker_params)
    case Repo.update(changeset) do
      {:ok, _beer_list_drinker} ->
        conn
        |> put_flash(:info, "Beer list drinker updated successfully.")
        |> redirect(to: page_path(conn, :index))
      {:error, changeset} ->
        render(conn, "edit.html", beer_list_drinker: beer_list_drinker, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    beer_list_drinker = Repo.get!(BeerListDrinker, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(beer_list_drinker)

    conn
    |> put_flash(:info, "Beer list drinker deleted successfully.")
    |> redirect(to: beer_list_drinker_path(conn, :index))
  end
end
