defmodule ClubHomepage.Repo.Migrations.AddShirtNumberToStandardTeamPlayers do
  use Ecto.Migration

  def change do
    alter table(:standard_team_players) do
      add :standard_shirt_number, :integer, default: nil
    end

    create unique_index(:standard_team_players, [:team_id, :standard_shirt_number], name: :index_standard_shirt_number_on_team_id)
  end
end
