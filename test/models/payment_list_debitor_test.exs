defmodule ClubHomepage.PaymentListDebitorTest do
  use ClubHomepage.ModelCase

  alias ClubHomepage.PaymentListDebitor

  import ClubHomepage.Factory

  @valid_attrs %{payment_list_id: 1, user_id: 1, number_of_units: 42}
  @invalid_attrs %{}

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
    assert changeset.errors[:payment_list_id] == {"can't be blank", []}
    assert changeset.errors[:user_id] == {"can't be blank", []}
    assert changeset.errors[:number_of_units] == {"can't be blank", []}
  end
end
