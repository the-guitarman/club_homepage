defmodule ClubHomepage.TeamImageController do
  use ClubHomepage.Web, :controller

  alias ClubHomepage.TeamImage

  plug :is_team_editor?
  plug :scrub_params, "team_image" when action in [:create, :update]
  plug :get_team_select_options when action in [:new, :new_bulk, :create, :create_bulk, :edit, :update]

  def index(conn, _params) do
    team_images = Repo.all(TeamImage)
    render(conn, "index.html", team_images: team_images)
  end

  def new(conn, params) do
    attributes = extract_team_id_attribute_from_parameters(params)
    changeset = TeamImage.changeset(%TeamImage{}, attributes)
    render(conn, "new.html", changeset: changeset,
           team_options: conn.assigns.team_options)
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
    render(conn, "edit.html", team_image: team_image, changeset: changeset,
           team_options: conn.assigns.team_options)
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

  defp get_team_select_options(conn, _) do
    query = from t in ClubHomepage.Team,
    select: {t.name, t.id},
    order_by: [asc: t.name]
    assign(conn, :team_options, Repo.all(query))
  end

  defp update_image(team_image, team_image_params) do
    TeamImage.image_changeset(team_image, team_image_params)
    |> Repo.update
  end

  defp extract_team_id_attribute_from_parameters(%{"team_id" => team_id}) do
    %{team_id: team_id}
  end
  defp extract_team_id_attribute_from_parameters(_) do
    %{}
  end
end
