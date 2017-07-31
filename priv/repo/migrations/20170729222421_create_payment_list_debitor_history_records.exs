defmodule ClubHomepage.Repo.Migrations.CreatePaymentListDebitorHistoryRecords do
  use Ecto.Migration

  def change do
    create table(:payment_list_debitor_history_records) do
      add :payment_list_debitor_id, references(:payment_list_debitors, on_delete: :delete_all)
      add :editor_id, references(:users), on_delete: :nilify_all
      add :old_number_of_units, :integer
      add :new_number_of_units, :integer

      timestamps()
    end

  end
end
