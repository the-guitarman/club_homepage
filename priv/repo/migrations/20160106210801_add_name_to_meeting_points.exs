defmodule ClubHomepage.Repo.Migrations.AddNameToMeetingPoints do
  use Ecto.Migration

  def change do
    alter table(:meeting_points) do
      add :name, :string
    end
  end
end
