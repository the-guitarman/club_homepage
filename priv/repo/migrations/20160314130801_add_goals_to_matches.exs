defmodule ClubHomepage.Repo.Migrations.AddGoalsToMatches do
  use Ecto.Migration

  def change do
    alter table(:matches) do
      add :team_goals, :integer
      add :opponent_team_goals, :integer
    end
  end
end
