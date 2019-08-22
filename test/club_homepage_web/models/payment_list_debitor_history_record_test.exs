defmodule ClubHomepage.PaymentListDebitorHistoryRecordTest do
  use ClubHomepage.ModelCase

  alias ClubHomepage.PaymentListDebitorHistoryRecord

  import ClubHomepage.Factory

  @valid_attrs %{payment_list_debitor_id: 1, editor_id: 1, old_number_of_units: 2, new_number_of_units: 4}
  @invalid_attrs %{}

  test "associations" do
    debitor = insert(:payment_list_debitor)
    editor = insert(:user)

    history_record =
      insert(:payment_list_debitor_history_record, payment_list_debitor_id: debitor.id, editor_id: editor.id)
      |> Repo.preload([:payment_list_debitor, :editor])
   
    assert history_record.payment_list_debitor == debitor
    assert history_record.editor == editor
  end

  test "changeset with valid attributes" do
    debitor = insert(:payment_list_debitor)
    editor = insert(:user)
    valid_attrs = %{@valid_attrs | payment_list_debitor_id: debitor.id, editor_id: editor.id}

    changeset = PaymentListDebitorHistoryRecord.changeset(%PaymentListDebitorHistoryRecord{}, valid_attrs)
    assert changeset.valid?
    assert Enum.empty?(changeset.errors)
  end

  test "changeset with invalid attributes" do
    changeset = PaymentListDebitorHistoryRecord.changeset(%PaymentListDebitorHistoryRecord{}, @invalid_attrs)
    refute changeset.valid?
    assert Enum.count(changeset.errors) == 4
    assert changeset.errors[:payment_list_debitor_id] == {"can't be blank", [validation: :required]}
    assert changeset.errors[:editor_id] == {"can't be blank", [validation: :required]}
    assert changeset.errors[:old_number_of_units] == {"can't be blank", [validation: :required]}
    assert changeset.errors[:new_number_of_units] == {"can't be blank", [validation: :required]}
  end

  test "number of units is greater than or equal to 0" do
    debitor = insert(:payment_list_debitor)
    editor = insert(:user)

    valid_attrs = %{@valid_attrs | payment_list_debitor_id: debitor.id, editor_id: editor.id, old_number_of_units: -1, new_number_of_units: -1}
    changeset = PaymentListDebitorHistoryRecord.changeset(%PaymentListDebitorHistoryRecord{}, valid_attrs)
    refute changeset.valid?
    refute Enum.empty?(changeset.errors)
    assert List.keymember?(changeset.errors, :old_number_of_units, 0)
    assert List.keymember?(changeset.errors, :new_number_of_units, 0)

    valid_attrs = %{@valid_attrs | payment_list_debitor_id: debitor.id, editor_id: editor.id, old_number_of_units: 0, new_number_of_units: 0}
    changeset = PaymentListDebitorHistoryRecord.changeset(%PaymentListDebitorHistoryRecord{}, valid_attrs)
    assert changeset.valid?
    assert Enum.empty?(changeset.errors)

    valid_attrs = %{@valid_attrs | payment_list_debitor_id: debitor.id, editor_id: editor.id, old_number_of_units: 1, new_number_of_units: 1}
    changeset = PaymentListDebitorHistoryRecord.changeset(%PaymentListDebitorHistoryRecord{}, valid_attrs)
    assert changeset.valid?
    assert Enum.empty?(changeset.errors)
  end
end
