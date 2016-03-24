defmodule ClubHomepage.TextPageController do
  use ClubHomepage.Web, :controller

  alias ClubHomepage.TextPage

  plug :scrub_params, "text_page" when action in [:create, :update]

  def index(conn, _params) do
    text_pages = Repo.all(TextPage)
    render(conn, "index.html", text_pages: text_pages)
  end

  def new(conn, _params) do
    changeset = TextPage.changeset(%TextPage{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"text_page" => text_page_params}) do
    changeset = TextPage.changeset(%TextPage{}, text_page_params)

    case Repo.insert(changeset) do
      {:ok, _text_page} ->
        conn
        |> put_flash(:info, "Text page created successfully.")
        |> redirect(to: text_page_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    text_page = Repo.get!(TextPage, id)
    render(conn, "show.html", text_page: text_page)
  end

  def edit(conn, %{"id" => id}) do
    text_page = Repo.get!(TextPage, id)
    changeset = TextPage.changeset(text_page)
    render(conn, "edit.html", text_page: text_page, changeset: changeset)
  end

  def update(conn, %{"id" => id, "text_page" => text_page_params}) do
    text_page = Repo.get!(TextPage, id)
    changeset = TextPage.changeset(text_page, text_page_params)

    case Repo.update(changeset) do
      {:ok, text_page} ->
        conn
        |> put_flash(:info, "Text page updated successfully.")
        |> redirect(to: text_page_path(conn, :show, text_page))
      {:error, changeset} ->
        render(conn, "edit.html", text_page: text_page, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    text_page = Repo.get!(TextPage, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(text_page)

    conn
    |> put_flash(:info, "Text page deleted successfully.")
    |> redirect(to: text_page_path(conn, :index))
  end
end
