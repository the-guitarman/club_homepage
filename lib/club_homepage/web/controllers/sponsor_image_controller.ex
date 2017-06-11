defmodule ClubHomepage.Web.SponsorImageController do
  use ClubHomepage.Web, :controller

  alias ClubHomepage.SponsorImage

  plug :is_text_page_editor?
  plug :scrub_params, "sponsor_image" when action in [:create, :update]

  def index(conn, _params) do
    sponsor_images = Repo.all(SponsorImage)
    render(conn, "index.html", sponsor_images: sponsor_images)
  end

  def new(conn, _params) do
    changeset = SponsorImage.changeset(%SponsorImage{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"sponsor_image" => sponsor_image_params}) do
    changeset1 = SponsorImage.changeset(%SponsorImage{}, sponsor_image_params)
    changeset2 = SponsorImage.image_changeset(%SponsorImage{}, sponsor_image_params)

    changeset = ClubHomepage.Web.ChangesetErrorsMerger.merge(changeset1, changeset2)

    case Repo.insert(changeset) do
      {:ok, sponsor_image} ->
        update_image(sponsor_image, sponsor_image_params)

        conn
        |> put_flash(:info, gettext("sponsor_image_created_successfully"))
        |> redirect(to: sponsor_image_path(conn, :index) <> "#sponsor-image-#{sponsor_image.id}")
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def edit(conn, %{"id" => id}) do
    sponsor_image = Repo.get!(SponsorImage, id)
    changeset = SponsorImage.changeset(sponsor_image)
    render(conn, "edit.html", sponsor_image: sponsor_image, changeset: changeset)
  end

  def update(conn, %{"id" => id, "sponsor_image" => sponsor_image_params}) do
    sponsor_image = Repo.get!(SponsorImage, id)
    changeset1 = SponsorImage.changeset(sponsor_image, sponsor_image_params)
    changeset2 = SponsorImage.image_changeset(sponsor_image, sponsor_image_params)

    changeset = ClubHomepage.Web.ChangesetErrorsMerger.merge(changeset1, changeset2)

    case Repo.update(changeset) do
      {:ok, sponsor_image} ->
        update_image(sponsor_image, sponsor_image_params)

        conn
        |> put_flash(:info, gettext("sponsor_image_updated_successfully"))
        |> redirect(to: sponsor_image_path(conn, :index) <> "#sponsor-image-#{sponsor_image.id}")
      {:error, changeset} ->
        render(conn, "edit.html", sponsor_image: sponsor_image, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    sponsor_image = Repo.get!(SponsorImage, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(sponsor_image)

    File.rm_rf!(ClubHomepage.SponsorUploader.storage_dir(nil, {nil, sponsor_image}))

    conn
    |> put_flash(:info, gettext("sponsor_image_deleted_successfully"))
    |> redirect(to: sponsor_image_path(conn, :index))
  end

  def update_image(sponsor_image, sponsor_image_params) do
    SponsorImage.image_changeset(sponsor_image, sponsor_image_params)
    |> Repo.update
  end
end
