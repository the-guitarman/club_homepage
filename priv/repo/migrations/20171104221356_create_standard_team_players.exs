defmodule ClubHomepage.Repo.Migrations.CreateStandardTeamPlayers do
  use Ecto.Migration

  def change do
    create table(:standard_team_players) do
      add :team_id, references(:teams)
      add :user_id, references(:users)

      timestamps()
    end

    create unique_index(:standard_team_players, [:team_id, :user_id])
  end
end
