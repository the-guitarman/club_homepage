defmodule ClubHomepage.Repo.Migrations.AddMeetingPointAtToMatches do
  use Ecto.Migration

  def change do
    alter table(:matches) do
      add :meeting_point_at, :datetime
    end
  end
end
