defmodule ClubHomepage.TeamImageController do
  use ClubHomepage.Web, :controller

  alias ClubHomepage.TeamImage

  plug :is_team_editor?
  plug :scrub_params, "team_image" when action in [:create, :update]

  def index(conn, _params) do
    team_images = Repo.all(TeamImage)
    render(conn, "index.html", team_images: team_images)
  end

  def new(conn, _params) do
    changeset = TeamImage.changeset(%TeamImage{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"team_image" => team_image_params}) do
    changeset1 = TeamImage.changeset(%TeamImage{}, team_image_params)
    changeset2 = TeamImage.image_changeset(%TeamImage{}, team_image_params)

    changeset = ClubHomepage.ChangesetErrorsMerger.merge(changeset1, changeset2)

    case Repo.insert(changeset) do
      {:ok, team_image} ->
        update_image(team_image, team_image_params)

        conn
        |> put_flash(:info, "Team image created successfully.")
        |> redirect(to: team_image_path(conn, :index) <> "#team-image-#{team_image.id}")
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def edit(conn, %{"id" => id}) do
    team_image = Repo.get!(TeamImage, id)
    changeset = TeamImage.changeset(team_image)
    render(conn, "edit.html", team_image: team_image, changeset: changeset)
  end

  def update(conn, %{"id" => id, "team_image" => team_image_params}) do
    team_image = Repo.get!(TeamImage, id)
    changeset1 = TeamImage.changeset(team_image, team_image_params)
    changeset2 = TeamImage.image_changeset(team_image, team_image_params)

    changeset = ClubHomepage.ChangesetErrorsMerger.merge(changeset1, changeset2)

    case Repo.update(changeset) do
      {:ok, team_image} ->
        update_image(team_image, team_image_params)

        conn
        |> put_flash(:info, "Team image updated successfully.")
        |> redirect(to: team_image_path(conn, :index) <> "#team-image-#{team_image.id}")
      {:error, changeset} ->
        render(conn, "edit.html", team_image: team_image, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    team_image = Repo.get!(TeamImage, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(team_image)

    conn
    |> put_flash(:info, "Team image deleted successfully.")
    |> redirect(to: team_image_path(conn, :index))
  end

  def update_image(team_image, team_image_params) do
    TeamImage.image_changeset(team_image, team_image_params)
    |> Repo.update
  end
end
