defmodule ClubHomepage.Repo.Migrations.RenameBeerListsToPaymentLists do
  use Ecto.Migration

  def change do
    drop index(:beer_lists, [:user_id])
    drop index(:beer_lists, [:deputy_id])

    rename table(:beer_lists), to: table(:payment_lists)
    rename table(:payment_lists), :price_per_beer, to: :price_per_unit

    create index(:payment_lists, [:user_id])
    create index(:payment_lists, [:deputy_id])
  end
end
