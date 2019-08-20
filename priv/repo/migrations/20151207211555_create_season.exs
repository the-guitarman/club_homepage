defmodule ClubHomepage.Repo.Migrations.CreateSeason do
  use Ecto.Migration

  def change do
    create table(:seasons) do
      add :name, :string

      timestamps([type: :utc_datetime])
    end

    create unique_index(:seasons, [:name])
  end
end
