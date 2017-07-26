defmodule ClubHomepage.Web.MyPaymentListsTest do
  use ClubHomepage.Web.ConnCase
  alias ClubHomepage.Web.MyPaymentLists

  import ClubHomepage.Factory

  test "my_payment_lists returns an empty list without a user" do
    my_payment_lists = MyPaymentLists.my_payment_lists(nil)
    assert Enum.empty?(my_payment_lists)
  end

  test "my_payment_lists returns an empty list, if the user has no payment list" do
    user = insert(:user)
    my_payment_lists = MyPaymentLists.my_payment_lists(user)
    assert Enum.empty?(my_payment_lists)
  end

  test "my_payment_lists returns a list with the users payment lists, if the user has a payment list" do
    user = insert(:user)

    _payment_list = insert(:payment_list, user_id: user.id)
    my_payment_lists = MyPaymentLists.my_payment_lists(user)
    refute Enum.empty?(my_payment_lists)
    assert Enum.count(my_payment_lists) == 1

    _payment_list = insert(:payment_list, user_id: user.id)
    my_payment_lists = MyPaymentLists.my_payment_lists(user)
    refute Enum.empty?(my_payment_lists)
    assert Enum.count(my_payment_lists) == 2
  end

  test "my_payment_list_debts returns an empty list without a user" do
    my_payment_list_debts = MyPaymentLists.my_payment_list_debitors(nil)
    assert Enum.empty?(my_payment_list_debts)
  end

  test "my_payment_list_debts returns an empty list, if the given user is not a payment list debitor" do
    user = insert(:user)
    my_payment_lists = MyPaymentLists.my_payment_list_debitors(user)
    assert Enum.empty?(my_payment_lists)
  end

  test "my_payment_list_debts returns a list with payment list debitors, if the given user is a payment list debitor" do
    user1 = insert(:user)
    user2 = insert(:user)
    payment_list = insert(:payment_list, user_id: user1.id)

    my_payment_list_debitors = MyPaymentLists.my_payment_list_debitors(user2)
    assert Enum.empty?(my_payment_list_debitors)
    assert Enum.count(my_payment_list_debitors) == 0

    payment_list_debitor = insert(:payment_list_debitor, payment_list_id: payment_list.id, user_id: user2.id)
    my_payment_list_debitors = MyPaymentLists.my_payment_list_debitors(user2)
    refute Enum.empty?(my_payment_list_debitors)
    assert Enum.count(my_payment_list_debitors) == 1

    payment_list_debitor = insert(:payment_list_debitor, payment_list_id: payment_list.id, user_id: user2.id)
    my_payment_list_debitors = MyPaymentLists.my_payment_list_debitors(user2)
    refute Enum.empty?(my_payment_list_debitors)
    assert Enum.count(my_payment_list_debitors) == 2
  end
end
