defmodule ClubHomepage.Repo.Migrations.RemoveFussballDeSeasonTableCacheFromTeams do
  use Ecto.Migration

  def change do
    alter table(:teams) do
      remove :current_table_html
      remove :current_table_html_at
    end
  end
end
