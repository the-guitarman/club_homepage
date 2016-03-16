defmodule ClubHomepage.Repo.Migrations.AddCometitionIdToMatchesAndTeams do
  use Ecto.Migration

  def change do
    alter table(:matches) do
      add :competition_id, references(:competitions)
    end
    alter table(:teams) do
      add :competition_id, references(:competitions)
    end
  end
end
