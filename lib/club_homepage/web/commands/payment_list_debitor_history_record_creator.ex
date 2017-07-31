defmodule ClubHomepage.Web.PaymentListDebitorHistoryRecordCreator do
  alias ClubHomepage.PaymentListDebitor
  alias ClubHomepage.PaymentListDebitorHistoryRecord, as: HistoryRecord
  alias ClubHomepage.Repo
  alias ClubHomepage.User

  @spec run(PaymentListDebitor, User) :: {:ok, PaymentListDebitor} | {:error, Ecto.Changeset.t}
  def run(new_debitor, editor) do
    create_record(new_debitor, 0, new_debitor.number_of_units, editor)
  end
  @spec run(PaymentListDebitor, PaymentListDebitor, User) :: {:ok, PaymentListDebitor} | {:error, Ecto.Changeset.t}
  def run(debitor, updated_debitor, editor) do
    create_record(debitor, debitor.number_of_units, updated_debitor.number_of_units, editor)
  end

  defp create_record(debitor, old_number_of_units, new_number_of_units, editor) do
    HistoryRecord.changeset(%HistoryRecord{payment_list_debitor_id: debitor.id, editor_id: editor.id, old_number_of_units: old_number_of_units, new_number_of_units: new_number_of_units})
    |> Repo.insert()
  end
end
