defmodule ClubHomepage.Repo.Migrations.CreateTeam do
  use Ecto.Migration

  def change do
    create table(:teams) do
      add :name, :string
      add :rewrite, :string

      timestamps
    end

  end
end
