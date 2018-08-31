defmodule ClubHomepage.Repo.Migrations.AddMoreFussballDeFieldsToTeams do
  use Ecto.Migration

  def change do
    alter table(:teams) do
      add :fussball_de_show_next_matches, :boolean, default: false
      add :fussball_de_show_current_table, :boolean, default: false
    end
  end
end
