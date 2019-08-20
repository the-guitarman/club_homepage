defmodule ClubHomepage.Web.PermalinkController do
  use ClubHomepage.Web, :controller

  alias ClubHomepage.Permalink

  plug :is_administrator
  plug :scrub_params, "permalink" when action in [:create, :update]

  def index(conn, _params) do
    permalinks = Repo.all(Permalink)
    render(conn, "index.html", permalinks: permalinks)
  end

  def new(conn, _params) do
    changeset = Permalink.changeset(%Permalink{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"permalink" => permalink_params}) do
    changeset = Permalink.changeset(%Permalink{}, permalink_params)

    case Repo.insert(changeset) do
      {:ok, _permalink} ->
        conn
        |> put_flash(:info, gettext("permalink_created_successfully"))
        |> redirect(to: Routes.permalink_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    permalink = Repo.get!(Permalink, id)
    render(conn, "show.html", permalink: permalink)
  end

  def edit(conn, %{"id" => id}) do
    permalink = Repo.get!(Permalink, id)
    changeset = Permalink.changeset(permalink)
    render(conn, "edit.html", permalink: permalink, changeset: changeset)
  end

  def update(conn, %{"id" => id, "permalink" => permalink_params}) do
    permalink = Repo.get!(Permalink, id)
    changeset = Permalink.changeset(permalink, permalink_params)

    case Repo.update(changeset) do
      {:ok, permalink} ->
        conn
        |> put_flash(:info, gettext("permalink_updated_successfully"))
        |> redirect(to: Routes.permalink_path(conn, :show, permalink))
      {:error, changeset} ->
        render(conn, "edit.html", permalink: permalink, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    permalink = Repo.get!(Permalink, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(permalink)

    conn
    |> put_flash(:info, gettext("permalink_deleted_successfully"))
    |> redirect(to: Routes.permalink_path(conn, :index))
  end
end
