defmodule ClubHomepage.Repo.Migrations.CreateBeerListDrinker do
  use Ecto.Migration

  def change do
    create table(:beer_list_drinkers) do
      add :beers, :integer
      add :beer_list_id, references(:beer_lists, on_delete: :nothing)
      add :user_id, references(:users, on_delete: :nothing)

      timestamps([type: :utc_datetime])
    end
    create index(:beer_list_drinkers, [:beer_list_id])
    create index(:beer_list_drinkers, [:user_id])

  end
end
