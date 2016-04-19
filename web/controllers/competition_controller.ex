defmodule ClubHomepage.CompetitionController do
  use ClubHomepage.Web, :controller

  alias ClubHomepage.Competition

  plug :has_role_from_list?, [roles: ["match-editor", "team-editor"]]
  plug :scrub_params, "competition" when action in [:create, :update]

  def index(conn, _params) do
    competitions = Repo.all(from(c in Competition, order_by: [asc: c.name]))
    render(conn, "index.html", competitions: competitions)
  end

  def new(conn, _params) do
    changeset = Competition.changeset(%Competition{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"competition" => competition_params}) do
    changeset = Competition.changeset(%Competition{}, competition_params)

    case Repo.insert(changeset) do
      {:ok, _competition} ->
        conn
        |> put_flash(:info, "Competition created successfully.")
        |> redirect(to: competition_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    competition = Repo.get!(Competition, id)
    render(conn, "show.html", competition: competition)
  end

  def edit(conn, %{"id" => id}) do
    competition = Repo.get!(Competition, id)
    changeset = Competition.changeset(competition)
    render(conn, "edit.html", competition: competition, changeset: changeset)
  end

  def update(conn, %{"id" => id, "competition" => competition_params}) do
    competition = Repo.get!(Competition, id)
    changeset = Competition.changeset(competition, competition_params)

    case Repo.update(changeset) do
      {:ok, competition} ->
        conn
        |> put_flash(:info, "Competition updated successfully.")
        |> redirect(to: competition_path(conn, :show, competition))
      {:error, changeset} ->
        render(conn, "edit.html", competition: competition, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    competition = Repo.get!(Competition, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(competition)

    conn
    |> put_flash(:info, "Competition deleted successfully.")
    |> redirect(to: competition_path(conn, :index))
  end
end
