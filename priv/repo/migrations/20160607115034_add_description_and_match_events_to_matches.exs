defmodule ClubHomepage.Repo.Migrations.AddDescriptionAndMatchEventsToMatches do
  use Ecto.Migration

  def change do
    alter table(:matches) do
      add :description, :text
      add :match_events, :text
    end
  end
end
