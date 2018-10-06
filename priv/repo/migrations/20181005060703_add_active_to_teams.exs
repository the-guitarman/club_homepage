defmodule ClubHomepage.Repo.Migrations.AddActiveToTeams do
  use Ecto.Migration

  def change do
    alter table(:teams) do
      add :active, :boolean, default: true
    end
  end
end
