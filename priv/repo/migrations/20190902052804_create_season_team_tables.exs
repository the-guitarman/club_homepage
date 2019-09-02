defmodule ClubHomepage.Repo.Migrations.CreateSeasonTeamTables do
  use Ecto.Migration

  def change do
    create table(:season_team_tables) do
      add :html, :text
      add :season_id, references(:seasons, on_delete: :delete_all)
      add :team_id, references(:teams, on_delete: :delete_all)

      timestamps()
    end

    create index(:season_team_tables, [:season_id])
    create index(:season_team_tables, [:team_id])
    create unique_index(:season_team_tables, [:season_id, :team_id], name: "unique_season_team_tables_index")
  end
end
