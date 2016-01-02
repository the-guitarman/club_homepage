defmodule ClubHomepage.OpponentTeamController do
  use ClubHomepage.Web, :controller

  alias ClubHomepage.OpponentTeam

  plug :scrub_params, "opponent_team" when action in [:create, :update]

  def index(conn, _params) do
    opponent_teams = Repo.all(OpponentTeam)
    render(conn, "index.html", opponent_teams: opponent_teams)
  end

  def new(conn, _params) do
    changeset = OpponentTeam.changeset(%OpponentTeam{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"opponent_team" => opponent_team_params}) do
    changeset = OpponentTeam.changeset(%OpponentTeam{}, opponent_team_params)

    case Repo.insert(changeset) do
      {:ok, _opponent_team} ->
        conn
        |> put_flash(:info, "Opponent team created successfully.")
        |> redirect(to: opponent_team_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    opponent_team = Repo.get!(OpponentTeam, id)
    render(conn, "show.html", opponent_team: opponent_team)
  end

  def edit(conn, %{"id" => id}) do
    opponent_team = Repo.get!(OpponentTeam, id)
    changeset = OpponentTeam.changeset(opponent_team)
    render(conn, "edit.html", opponent_team: opponent_team, changeset: changeset)
  end

  def update(conn, %{"id" => id, "opponent_team" => opponent_team_params}) do
    opponent_team = Repo.get!(OpponentTeam, id)
    changeset = OpponentTeam.changeset(opponent_team, opponent_team_params)

    case Repo.update(changeset) do
      {:ok, opponent_team} ->
        conn
        |> put_flash(:info, "Opponent team updated successfully.")
        |> redirect(to: opponent_team_path(conn, :show, opponent_team))
      {:error, changeset} ->
        render(conn, "edit.html", opponent_team: opponent_team, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    opponent_team = Repo.get!(OpponentTeam, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(opponent_team)

    conn
    |> put_flash(:info, "Opponent team deleted successfully.")
    |> redirect(to: opponent_team_path(conn, :index))
  end
end
