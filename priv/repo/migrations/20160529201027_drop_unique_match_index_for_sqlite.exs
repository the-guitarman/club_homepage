defmodule ClubHomepage.Repo.Migrations.DropUniqueMatchIndexForSqlite do
  use Ecto.Migration

  def change do
    if ClubHomepage.ModelValidator.is_sqlite_adapter? do
      drop unique_index(:matches, [:season_id, :team_id, :opponent_team_id, :home_match], name: "unique_match_index")
    end
  end
end
