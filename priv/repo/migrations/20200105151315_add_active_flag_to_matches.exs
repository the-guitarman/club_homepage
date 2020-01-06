defmodule ClubHomepage.Repo.Migrations.AddActiveFlagToMatches do
  use Ecto.Migration

  def change do
    alter table(:matches) do
      add :active, :boolean, default: true
    end

    #if exists? table(:matches) do
      flush()
      ClubHomepage.Repo.update_all("matches", set: [active: true])
      #execute "UPDATE matches SET active = 1"
    #end
  end
end
