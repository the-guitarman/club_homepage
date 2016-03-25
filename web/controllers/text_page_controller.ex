defmodule ClubHomepage.TextPageController do
  use ClubHomepage.Web, :controller

  alias ClubHomepage.TextPage

  plug :scrub_params, "text_page" when action in [:update]

  def index(conn, _params) do
    text_pages = Repo.all(from(tp in TextPage, order_by: [asc: tp.key]))
    render(conn, "index.html", text_pages: text_pages)
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
        |> redirect(to: text_page_path(conn, :index))
      {:error, changeset} ->
        render(conn, "edit.html", text_page: text_page, changeset: changeset)
    end
  end
end
