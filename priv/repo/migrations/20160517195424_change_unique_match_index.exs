defmodule ClubHomepage.Repo.Migrations.ChangeUniqueMatchIndex do
  use Ecto.Migration

  def change do
    drop unique_index(:matches, [:season_id, :team_id, :opponent_team_id], name: "unique_match_index")
    create unique_index(:matches, [:season_id, :team_id, :opponent_team_id, :home_match], name: "unique_match_index")
  end
end
