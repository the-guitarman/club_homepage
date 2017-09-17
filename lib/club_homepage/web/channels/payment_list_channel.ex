defmodule ClubHomepage.Web.PaymentListChannel do
  use ClubHomepage.Web, :channel

  alias Number.Currency
  alias ClubHomepage.Repo
  alias ClubHomepage.PaymentListDebitor

  def join("payment-lists:" <> payment_list_id, _payload, socket) do
    payment_list_id = String.to_integer(payment_list_id)
    {:ok, assign(socket, :payment_list_id, payment_list_id)}
  end

  def handle_in("number_of_units:apply_delta", %{"payment_list_id" => payment_list_id, "debitor_id" => debitor_id, "number_of_units_delta" => delta_value}, socket) do
    update_map_callback = fn(debitor) -> %{number_of_units: debitor.number_of_units + delta_value} end

    {_, _, _, number_of_units, sum} = result = update_debitor(socket, payment_list_id, debitor_id, update_map_callback)

    broadcast! socket, "number_of_units:updated", %{payment_list_id: payment_list_id, debitor_id: debitor_id, number_of_units: number_of_units, sum: sum}
    get_reply(result)
  end

  def handle_in("number_of_units:reset", %{"payment_list_id" => payment_list_id, "debitor_id" => debitor_id, "number_of_units" => _value}, socket) do
    update_map_callback = fn(_) -> %{number_of_units: 0} end

    socket
    |> update_debitor(payment_list_id, debitor_id, update_map_callback)
    |> get_reply()
  end

  intercept ["number_of_units:updated"]

  def handle_out("number_of_units:updated", msg, socket) do
    %{debitor_id: debitor_id} = msg
    debitor = get_debitor(debitor_id)
    if debitor.user.id == socket.assigns[:current_user].id do
      push socket, "number_of_units:updated", msg
    end
    {:noreply, socket}
  end

  defp update_debitor(socket, payment_list_id, debitor_id, update_map_callback) do
    debitor = get_debitor(debitor_id)
    changeset = PaymentListDebitor.changeset(debitor, update_map_callback.(debitor))
    new_number_of_units =
      case Repo.update(changeset) do
        {:ok, updated_debitor} -> updated_debitor.number_of_units
        {:error, _} -> debitor.number_of_units
      end
    sum = Currency.number_to_currency(new_number_of_units * debitor.payment_list.price_per_piece)
    {socket, payment_list_id, debitor_id, new_number_of_units, sum}
  end

  defp get_debitor(id) do
    Repo.get(PaymentListDebitor, id)
    |> Repo.preload([:payment_list, :user])
  end

  defp get_reply({socket, payment_list_id, debitor_id, number_of_units, sum}) do
    #    push socket, "number_of_units:apply_delta", %{"payment_list_id" => payment_list_id, debitor_id: debitor_id, number_of_units: number_of_units, sum: sum}
    #    {:noreply, socket}
    {:reply, {:ok, %{"payment_list_id" => payment_list_id, debitor_id: debitor_id, number_of_units: number_of_units, sum: sum}}, socket}
  end
end
