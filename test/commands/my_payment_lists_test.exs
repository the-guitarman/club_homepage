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
end
