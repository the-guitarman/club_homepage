defmodule ClubHomepage.Repo.Migrations.AddUniqueIndexToNameOfMeetingPoints do
  use Ecto.Migration

  def change do
    create unique_index(:meeting_points, [:name])
  end
end
