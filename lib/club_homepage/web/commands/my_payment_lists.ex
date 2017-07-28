defmodule ClubHomepage.Web.MyPaymentLists do
  @moduledoc """
  Provides payment lists for a user. You may be use it as a plug to assign the payment lists of the current user.
  """

  alias ClubHomepage.Repo
  alias ClubHomepage.PaymentList
  alias ClubHomepage.PaymentListDebitor
  alias ClubHomepage.User

  import Plug.Conn
  import Ecto.Query, only: [from: 2]
  #import ClubHomepage.Extension.Common, only: [internal_user_name: 1]
  import ClubHomepage.Web.Auth

  def init(_opts) do
    nil
  end

  def call(conn, _) do
    user = current_user(conn)
    conn
    |> assign(:my_payment_lists, my_payment_lists(user))
    |> assign(:my_payment_list_debitors, my_payment_list_debitors(user))
  end

  @doc """
  Returns payment lists for the provided user.
  """
  @spec my_payment_lists(User | Nil) :: List.t
  def my_payment_lists(nil), do: []
  def my_payment_lists(user) do
    user
    |> get_user_payment_lists_query
    |> get_user_records(PaymentList)
    |> Enum.map(fn(struct) -> Repo.preload(struct, [:user, :deputy]) end)
  end

  defp get_user_payment_lists_query(user) do
    from pl in PaymentList,
    left_join: pld in PaymentListDebitor,
    on: pl.id == pld.payment_list_id,
    where: pl.user_id == ^user.id,
    select: %{id: pl.id, user_id: pl.user_id, deputy_id: pl.deputy_id, title: pl.title, price_per_piece: pl.price_per_piece, number_of_debitors: count(pld.id)},
    order_by: [asc: pl.title],
    group_by: [pl.id, pl.user_id, pl.deputy_id, pl.title, pl.price_per_piece]
  end

  @spec my_payment_list_debitors(User | Nil) :: List.t
  def my_payment_list_debitors(nil), do: []
  def my_payment_list_debitors(user) do
    user
    |> get_user_payment_list_debts_query
    |> get_user_records(PaymentListDebitor)
    |> Enum.map(fn(struct) -> Repo.preload(struct, [:payment_list, :payment_list_owner, :payment_list_deputy]) end)
  end

  defp get_user_payment_list_debts_query(user) do
    from pld in PaymentListDebitor,
    left_join: pl in PaymentList,
    on: pld.payment_list_id == pl.id,
    where: pld.user_id == ^user.id,
    select: %{id: pld.id, payment_list_id: pld.payment_list_id, user_id: pld.user_id, number_of_units: pld.number_of_units, price_per_piece: pl.price_per_piece},
    order_by: [desc: pld.inserted_at]
  end

  defp get_user_records(query, model_module) do
    query
    |> Repo.all
    |> Enum.map(fn(map) -> struct(model_module, map) end)
  end
end
