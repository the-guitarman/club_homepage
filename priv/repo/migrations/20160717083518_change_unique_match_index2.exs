defmodule ClubHomepage.Repo.Migrations.ChangeUniqueMatchIndex2 do
  use Ecto.Migration

  def change do
    drop unique_index(:matches, [:season_id, :team_id, :opponent_team_id, :home_match], name: "unique_match_index")
    create unique_index(:matches, [:competition_id, :season_id, :team_id, :opponent_team_id, :home_match], name: "unique_match_index")
  end
end
