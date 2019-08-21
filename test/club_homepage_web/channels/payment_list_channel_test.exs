defmodule ClubHomepage.PaymentListChannelTest do
  use ClubHomepageWeb.ChannelCase

  alias ClubHomepageWeb.PaymentListChannel

  import ClubHomepage.Factory

  setup do
    user = insert(:user)
    payment_list = insert(:payment_list)
    {:ok, _, socket} =
      socket("users_socket: #{user.id}", %{current_user: user}, %{})
      |> subscribe_and_join(PaymentListChannel, "payment-lists:#{payment_list.id}")
    {:ok, socket: socket, current_user: user, payment_list: payment_list}
  end

  test "push number_of_units:apply_delta", %{socket: socket, payment_list: payment_list} do
    debitor = insert(:payment_list_debitor, payment_list_id: payment_list.id, number_of_units: 2)
    ref = push socket, "number_of_units:apply_delta", %{"payment_list_id" => payment_list.id, "debitor_id" => debitor.id, "number_of_units_delta" => 2}
    expected_payload = %{:debitor_id => debitor.id, :number_of_units => 4, :sum => "$4.00", payment_list_id: payment_list.id}
    #assert_push "number_of_units:updated", ^expected_payload
    assert_broadcast "number_of_units:updated", ^expected_payload, 5000
    assert_reply ref, :ok, ^expected_payload
    leave_socket(socket)
  end

  test "push number_of_units:reset", %{socket: socket, payment_list: payment_list} do
    debitor = insert(:payment_list_debitor, payment_list_id: payment_list.id, number_of_units: 2)
    ref = push socket, "number_of_units:reset", %{"payment_list_id" => payment_list.id, "debitor_id" => debitor.id, "number_of_units" => 0}
    expected_payload = %{:debitor_id => debitor.id, :number_of_units => 0, :sum => "$0.00", payment_list_id: payment_list.id}
    #assert_push "number_of_units:updated", ^expected_payload
    assert_broadcast "number_of_units:updated", ^expected_payload, 5000
    assert_reply ref, :ok, ^expected_payload
    leave_socket(socket)
  end
end
