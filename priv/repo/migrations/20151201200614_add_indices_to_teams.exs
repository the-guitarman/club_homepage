defmodule ClubHomepage.Repo.Migrations.AddIndicesToTeams do
  use Ecto.Migration

  def change do
    create unique_index(:teams, [:name])
    create unique_index(:teams, [:rewrite])
  end
end
