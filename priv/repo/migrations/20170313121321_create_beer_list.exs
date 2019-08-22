defmodule ClubHomepage.Repo.Migrations.CreateBeerList do
  use Ecto.Migration

  def change do
    create table(:beer_lists) do
      add :user_id, references(:users, on_delete: :nothing)
      add :deputy_id, references(:users, on_delete: :nothing)
      add :price_per_beer, :float
      add :title, :string

      timestamps([type: :utc_datetime])
    end
    create index(:beer_lists, [:user_id])
    create index(:beer_lists, [:deputy_id])

  end
end
