defmodule ClubHomepage.Repo.Migrations.AddMatchCharacterToCompetitions do
  use Ecto.Migration

  def change do
    alter table(:competitions) do
      add :matches_need_decition, :boolean, default: false
    end
  end
end
