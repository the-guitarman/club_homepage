defmodule ClubHomepage.OpponentTeamController do
  use ClubHomepage.Web, :controller

  alias ClubHomepage.OpponentTeam
  alias ClubHomepage.Repo

  plug :has_role_from_list?, [roles: ["match-editor", "team-editor"]]
  plug :scrub_params, "opponent_team" when action in [:create, :update]
  plug :get_address_select_options when action in [:new, :create, :edit, :update]

  def index(conn, _params) do
    opponent_teams = Repo.all(from(ot in OpponentTeam, preload: [:address], order_by: [asc: ot.name]))
    render(conn, "index.html", opponent_teams: opponent_teams)
  end

  def new(conn, _params) do
    changeset = OpponentTeam.changeset(%OpponentTeam{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"opponent_team" => opponent_team_params}) do
    changeset = OpponentTeam.changeset(%OpponentTeam{}, opponent_team_params)

    case Repo.insert(changeset) do
      {:ok, opponent_team} ->
        conn
        |> put_flash(:info, "Opponent team created successfully.")
        |> redirect(to: opponent_team_path(conn, :index) <> "#opponent-team-#{opponent_team.id}")
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
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
        |> redirect(to: opponent_team_path(conn, :index) <> "#opponent-team-#{opponent_team.id}")
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

  defp get_address_select_options(conn, _) do
    query = from(s in ClubHomepage.Address,
                 select: {[s.street, ", ", s.zip_code, " ", s.city], s.id},
                 order_by: [desc: s.street])
    assign(conn, :address_options, Repo.all(query))
  end
end
