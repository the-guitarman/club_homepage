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
    process(socket, payment_list_id, debitor_id, update_map_callback)
  end

  def handle_in("number_of_units:reset", %{"payment_list_id" => payment_list_id, "debitor_id" => debitor_id, "number_of_units" => _value}, socket) do
    update_map_callback = fn(debitor) -> %{number_of_units: 0} end
    process(socket, payment_list_id, debitor_id, update_map_callback)
  end

  defp process(socket, payment_list_id, debitor_id, update_map_callback) do
    debitor = get_debitor(debitor_id)
    changeset = PaymentListDebitor.changeset(debitor, update_map_callback.(debitor))
    value = update_debitor(changeset, debitor)
    sum = Currency.number_to_currency(value * debitor.payment_list.price_per_piece)
    push socket, "number_of_units:apply_delta", %{"payment_list_id" => payment_list_id, debitor_id: debitor_id, number_of_units: value, sum: sum}
    {:noreply, socket}
  end

  defp get_debitor(id) do
    Repo.get(PaymentListDebitor, id)
    |> Repo.preload([:payment_list])
  end

  defp update_debitor(changeset, debitor) do
    case Repo.update(changeset) do
      {:ok, updated_debitor} -> updated_debitor.number_of_units
      {:error, _} -> debitor.number_of_units
    end
  end
end
