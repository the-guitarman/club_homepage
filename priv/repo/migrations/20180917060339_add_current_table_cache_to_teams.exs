defmodule ClubHomepage.Repo.Migrations.AddCurrentTableCacheToTeams do
  use Ecto.Migration

  def change do
    alter table(:teams) do
      add :current_table_html, :text, default: nil
      add :current_table_html_at, :utc_datetime
    end
  end
end
