defmodule ClubHomepage.Repo.Migrations.RenameBeerListDrinkersToPaymentListDebitors do
  use Ecto.Migration

  def change do
    drop index(:beer_list_drinkers, [:beer_list_id])
    drop index(:beer_list_drinkers, [:user_id])

    rename table(:beer_list_drinkers), to: table(:payment_list_debitors)
    rename table(:payment_list_debitors), :beers, to: :number_of_units
    rename table(:payment_list_debitors), :beer_list_id, to: :payment_list_id

    create index(:payment_list_debitors, [:payment_list_id])
    create index(:payment_list_debitors, [:user_id])
  end
end
