defmodule ClubHomepage.SeasonController do
  use ClubHomepage.Web, :controller

  import ClubHomepage.Extension.SeasonController

  alias ClubHomepage.Season

  plug :is_match_editor?
  plug :scrub_params, "season" when action in [:create, :update]

  def index(conn, _params) do
    seasons = Repo.all(Season)
    render(conn, "index.html", seasons: seasons)
  end

  def new(conn, _params) do
    changeset = Season.changeset(%Season{})
    render(conn, "new.html", changeset: changeset, years: new_years)
  end

  def create(conn, %{"season" => season_params}) do
    changeset = Season.changeset(%Season{}, season_params)

    case Repo.insert(changeset) do
      {:ok, _season} ->
        conn
        |> put_flash(:info, gettext("season_created_successfully."))
        |> redirect(to: season_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset, years: new_years)
    end
  end

  def show(conn, %{"id" => id}) do
    season = Repo.get!(Season, id)
    render(conn, "show.html", season: season)
  end

  def edit(conn, %{"id" => id}) do
    season = Repo.get!(Season, id)
    changeset = Season.changeset(season)
    render(conn, "edit.html", season: season, changeset: changeset)
  end

  def update(conn, %{"id" => id, "season" => season_params}) do
    season = Repo.get!(Season, id)
    changeset = Season.changeset(season, season_params)

    case Repo.update(changeset) do
      {:ok, season} ->
        conn
        |> put_flash(:info, gettext("season_updated_successfully"))
        |> redirect(to: season_path(conn, :show, season))
      {:error, changeset} ->
        render(conn, "edit.html", season: season, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    season = Repo.get!(Season, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(season)

    conn
    |> put_flash(:info, gettext("season_deleted_successfully"))
    |> redirect(to: season_path(conn, :index))
  end
end
