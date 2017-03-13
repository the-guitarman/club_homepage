defmodule ClubHomepage.Repo.Migrations.CreateBeerList do
  use Ecto.Migration

  def change do
    create table(:beer_lists) do
      add :user_id, references(:users, on_delete: :nothing)
      add :deputy, references(:users, on_delete: :nothing)

      timestamps()
    end
    create index(:beer_lists, [:user_id])
    create index(:beer_lists, [:deputy])

  end
end
