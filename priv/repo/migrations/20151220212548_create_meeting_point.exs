defmodule ClubHomepage.Repo.Migrations.CreateMeetingPoint do
  use Ecto.Migration

  def change do
    create table(:meeting_points) do
      add :address_id, references(:addresses)

      timestamps([type: :utc_datetime])
    end
    create index(:meeting_points, [:address_id])
  end
end
