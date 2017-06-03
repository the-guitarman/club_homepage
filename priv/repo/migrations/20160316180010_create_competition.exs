defmodule ClubHomepage.Repo.Migrations.CreateCompetition do
  use Ecto.Migration

  def change do
    create table(:competitions) do
      add :name, :string

      timestamps()
    end

  end
end
