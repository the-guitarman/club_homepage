defmodule ClubHomepage.Repo.Migrations.CreateTeam do
  use Ecto.Migration

  def change do
    create table(:teams) do
      add :name, :string
      add :slug, :string

      timestamps([type: :utc_datetime])
    end

    create unique_index(:teams, [:name])
    create unique_index(:teams, [:slug])
  end
end
