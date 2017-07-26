defmodule ClubHomepage.PaymentListDebitorTest do
  use ClubHomepage.ModelCase

  alias ClubHomepage.PaymentListDebitor

  import ClubHomepage.Factory

  @valid_attrs %{payment_list_id: 1, user_id: 1, number_of_units: 42}
  @invalid_attrs %{}

  test "associations" do
    user1 = insert(:user)
    user2 = insert(:user)
    user3 = insert(:user)

    payment_list =
      insert(:payment_list, user_id: user1.id, deputy_id: user2.id)
      |> Repo.preload([:user, :deputy])
   
    payment_list_debitor =
      insert(:payment_list_debitor, payment_list_id: payment_list.id, user_id: user3.id)
      |> Repo.preload([:payment_list, :user, :payment_list_owner, :payment_list_deputy])

    assert payment_list_debitor.payment_list == payment_list
    assert payment_list_debitor.user == user3
    assert payment_list_debitor.payment_list_owner == user1
    assert payment_list_debitor.payment_list_deputy == user2
  end

  test "changeset with valid attributes" do
    payment_list = insert(:payment_list)
    user = insert(:user)
    valid_attrs = %{@valid_attrs | payment_list_id: payment_list.id, user_id: user.id}

    changeset = PaymentListDebitor.changeset(%PaymentListDebitor{}, valid_attrs)
    assert changeset.valid?
    assert Enum.empty?(changeset.errors)
  end

  test "changeset with invalid attributes" do
    changeset = PaymentListDebitor.changeset(%PaymentListDebitor{}, @invalid_attrs)
    refute changeset.valid?
    assert Enum.count(changeset.errors) == 3
    assert changeset.errors[:payment_list_id] == {"can't be blank", [validation: :required]}
    assert changeset.errors[:user_id] == {"can't be blank", [validation: :required]}
    assert changeset.errors[:number_of_units] == {"can't be blank", [validation: :required]}
  end

  test "number of units is greater than or equal to 0" do
    payment_list = insert(:payment_list)
    user = insert(:user)

    valid_attrs = %{@valid_attrs | payment_list_id: payment_list.id, user_id: user.id, number_of_units: -1}
    changeset = PaymentListDebitor.changeset(%PaymentListDebitor{}, valid_attrs)
    refute changeset.valid?
    refute Enum.empty?(changeset.errors)
    assert List.keymember?(changeset.errors, :number_of_units, 0)

    valid_attrs = %{@valid_attrs | payment_list_id: payment_list.id, user_id: user.id, number_of_units: 0}
    changeset = PaymentListDebitor.changeset(%PaymentListDebitor{}, valid_attrs)
    assert changeset.valid?
    assert Enum.empty?(changeset.errors)

    valid_attrs = %{@valid_attrs | payment_list_id: payment_list.id, user_id: user.id, number_of_units: 1}
    changeset = PaymentListDebitor.changeset(%PaymentListDebitor{}, valid_attrs)
    assert changeset.valid?
    assert Enum.empty?(changeset.errors)
  end
end
