defmodule ClubHomepage.Repo.Migrations.DropUniqueMatchIndex do
  use Ecto.Migration

  def change do
    drop unique_index(:matches, [:competition_id, :season_id, :team_id, :opponent_team_id, :home_match], name: "unique_match_index")
  end
end
