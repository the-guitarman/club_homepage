defmodule ClubHomepage.Repo.Migrations.AddFussballDeFieldsToTeams do
  use Ecto.Migration

  def change do
    alter table(:teams) do
      add :fussball_de_team_url, :text, null: true, default: nil
      add :fussball_de_team_rewrite, :string, null: true, default: nil
      add :fussball_de_team_id, :string, null: true, default: nil
    end
  end
end
