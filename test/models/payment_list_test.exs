defmodule ClubHomepage.PaymentListTest do
  use ClubHomepage.ModelCase

  alias ClubHomepage.PaymentList

  import ClubHomepage.Factory

  @valid_attrs %{user_id: 1, deputy_id: nil, title: "Team 1", price_per_unit: 1.5}
  @invalid_attrs %{title: "", price_per_unit: nil}

  test "changeset with valid attributes" do
    user = insert(:user)
    valid_attrs = %{@valid_attrs | user_id: user.id}

    changeset = PaymentList.changeset(%PaymentList{}, valid_attrs)
    assert changeset.valid?
    assert Enum.empty?(changeset.errors)

    valid_attrs = %{valid_attrs | deputy_id: user.id}

    changeset = PaymentList.changeset(%PaymentList{}, valid_attrs)
    refute changeset.valid?
    refute Enum.empty?(changeset.errors)
    assert changeset.errors[:deputy_id] == {"owner and deputy can't be the same person", []}

    deputy = insert(:user)
    valid_attrs = %{@valid_attrs | deputy_id: deputy.id}

    changeset = PaymentList.changeset(%PaymentList{}, valid_attrs)
    assert changeset.valid?
    assert Enum.empty?(changeset.errors)
    refute changeset.errors[:deputy_id] == {"owner and deputy can't be the same person", []}
  end

  test "changeset with invalid attributes" do
    changeset = PaymentList.changeset(%PaymentList{}, @invalid_attrs)
    changeset.valid?
    refute changeset.valid?
    assert Enum.count(changeset.errors) == 3
    assert changeset.errors[:user_id] == {"can't be blank", []}
    refute changeset.errors[:deputy_id] == {"can't be blank", []}
    assert changeset.errors[:title] == {"can't be blank", []}
    assert changeset.errors[:price_per_unit] == {"can't be blank", []}
  end
end
