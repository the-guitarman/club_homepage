defmodule ClubHomepage.Repo.Migrations.AddFussballDeLastNewMatchesCheckAtToTeams do
  use Ecto.Migration

  def change do
    alter table(:teams) do
      add :fussball_de_last_next_matches_check_at, :utc_datetime
    end
  end
end
