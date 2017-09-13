defmodule ClubHomepage.Web.PaymentListChannel do
  use ClubHomepage.Web, :channel

  alias Number.Currency
  alias ClubHomepage.Repo
  alias ClubHomepage.PaymentListDebitor

  def join("payment-lists:" <> payment_list_id, _payload, socket) do
    payment_list_id = String.to_integer(payment_list_id)
    #current_user = socket.assigns.current_user
    #response = %{}
    #{:ok, response, assign(socket, :payment_list_id, payment_list_id)}
    {:ok, assign(socket, :payment_list_id, payment_list_id)}
  end

  def handle_in("apply_delta_value", %{"payment_list_id" => payment_list_id, "debitor_id" => debitor_id, "number_of_units_delta" => delta_value}, socket) do
    debitor =
      Repo.get(PaymentListDebitor, debitor_id)
      |> Repo.preload([:payment_list])
    changeset = PaymentListDebitor.changeset(debitor, %{number_of_units: debitor.number_of_units + delta_value})
    value =
      case Repo.update(changeset) do
        {:ok, updated_debitor} -> updated_debitor.number_of_units
        {:error, _} -> debitor.number_of_units
      end
    sum = Currency.number_to_currency(value * debitor.payment_list.price_per_piece)
    push socket, "apply_delta_value", %{"payment_list_id" => payment_list_id, debitor_id: debitor_id, number_of_units: value, sum: sum}
    {:noreply, socket}
  end

  def handle_in("reset_value", %{"payment_list_id" => payment_list_id, "debitor_id" => debitor_id, "number_of_units" => _value}, socket) do
    debitor =
      Repo.get(PaymentListDebitor, debitor_id)
      |> Repo.preload([:payment_list])
    changeset = PaymentListDebitor.changeset(debitor, %{number_of_units: 0})
    value =
      case Repo.update(changeset) do
        {:ok, updated_debitor} -> updated_debitor.number_of_units
        {:error, _} -> debitor.number_of_units
      end
    sum = Currency.number_to_currency(value * debitor.payment_list.price_per_piece)
    push socket, "apply_delta_value", %{"payment_list_id" => payment_list_id, debitor_id: debitor_id, number_of_units: value, sum: sum}
    {:noreply, socket}
  end
end
