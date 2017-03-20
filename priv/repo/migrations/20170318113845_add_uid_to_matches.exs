defmodule ClubHomepage.Repo.Migrations.AddUidToMatches do
  use Ecto.Migration

  def change do
    alter table(:matches) do
      add :uid, :string
    end
  end
end
