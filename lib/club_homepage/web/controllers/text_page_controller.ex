defmodule ClubHomepage.Web.TextPageController do
  use ClubHomepage.Web, :controller

  alias ClubHomepage.TextPage

  plug :is_text_page_editor?
  plug :scrub_params, "text_page" when action in [:update]

  def index(conn, _params) do
    text_pages = Repo.all(from(tp in TextPage, order_by: [asc: tp.key]))
    render(conn, "index.html", text_pages: text_pages)
  end

  def edit(conn, %{"id" => id}) do
    text_page = Repo.get!(TextPage, id)
    changeset = TextPage.changeset(text_page)
    sponsor_images = get_sponsor_images(text_page)
    render(conn, "edit.html", text_page: text_page, changeset: changeset, sponsor_images: sponsor_images)
  end

  def update(conn, %{"id" => id, "text_page" => text_page_params}) do
    text_page = Repo.get!(TextPage, id)
    changeset = TextPage.changeset(text_page, text_page_params)

    case Repo.update(changeset) do
      {:ok, _text_page} ->
        conn
        |> put_flash(:info, gettext("text_page_updated_successfully"))
        |> redirect(to: text_page_path(conn, :index))
      {:error, changeset} ->
        sponsor_images = get_sponsor_images(text_page)
        render(conn, "edit.html", text_page: text_page, changeset: changeset, sponsor_images: sponsor_images)
    end
  end

  defp get_sponsor_images(text_page) do
    case text_page.key do
      "/sponsors.html" -> Repo.all(ClubHomepage.SponsorImage)
      _ -> []
    end
  end
end
