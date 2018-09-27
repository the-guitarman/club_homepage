defmodule ClubHomepage.Repo.Migrations.AddFussballDeMatchIdToMatches do
  use Ecto.Migration

  def change do
    alter table(:matches) do
      add :fussball_de_match_id, :string, default: nil
    end
  end
end
