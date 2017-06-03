defmodule ClubHomepage.Repo.Migrations.CreateOpponentTeam do
  use Ecto.Migration

  def change do
    create table(:opponent_teams) do
      add :name, :string
      add :address_id, references(:addresses)

      timestamps()
    end

    create index(:opponent_teams, [:address_id])

    create unique_index(:opponent_teams, [:name])
  end
end
