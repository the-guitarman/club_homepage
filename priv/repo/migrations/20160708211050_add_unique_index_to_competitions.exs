defmodule ClubHomepage.Repo.Migrations.AddUniqueIndexToCompetitions do
  use Ecto.Migration

  def change do
    create unique_index(:competitions, [:name])
  end
end
