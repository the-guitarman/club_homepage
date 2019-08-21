defmodule ClubHomepageWeb.PaymentListDebitorHistoryRecordCreatorTest do
  use ClubHomepageWeb.ConnCase

  alias ClubHomepage.PaymentListDebitor
  alias ClubHomepage.PaymentListDebitorHistoryRecord, as: HistoryRecord
  alias ClubHomepageWeb.PaymentListDebitorHistoryRecordCreator, as: HistoryRecordCreator

  import ClubHomepage.Factory

  test "creation of a new PaymentListDebitor" do
    debitor = insert(:payment_list_debitor, number_of_units: 5)
    editor = insert(:user)

    refute Repo.get_by(HistoryRecord, payment_list_debitor_id: debitor.id, editor_id: editor.id)

    {:ok, new_history_record} = HistoryRecordCreator.run(debitor, editor)
    assert new_history_record

    history_record = Repo.get_by(HistoryRecord, payment_list_debitor_id: debitor.id, editor_id: editor.id)
    assert history_record
    assert history_record.id == new_history_record.id
    assert history_record.old_number_of_units == 0
    assert history_record.new_number_of_units == 5
    assert history_record.new_number_of_units == debitor.number_of_units
  end

  test "update of an existing PaymentListDebitor" do
    history_record =
      insert(:payment_list_debitor_history_record)
      |> Repo.preload([:payment_list_debitor])
    debitor = history_record.payment_list_debitor
    editor = insert(:user)

    changeset = PaymentListDebitor.changeset(debitor, %{number_of_units: 99})
    {:ok, updated_debitor} = Repo.update(changeset)

    {:ok, new_history_record} = HistoryRecordCreator.run(debitor, updated_debitor, editor)
    assert new_history_record
    assert new_history_record.id > history_record.id
    assert new_history_record.old_number_of_units == debitor.number_of_units
    assert new_history_record.new_number_of_units == 99
    assert new_history_record.new_number_of_units == updated_debitor.number_of_units
  end
end
