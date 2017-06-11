defmodule ClubHomepage.MyPaymentLists do
  @moduledoc """
  Provides payment lists for a user. You may be use it as a plug to assign the payment lists of the current user.
  """

  alias ClubHomepage.Repo
  alias ClubHomepage.PaymentList
  alias ClubHomepage.PaymentListDebitor
  alias ClubHomepage.User

  import Plug.Conn
  import Ecto.Query, only: [from: 2]
  #import ClubHomepage.Extension.CommonMatch, only: [internal_user_name: 1]
  import ClubHomepage.Web.Auth

  def init(_opts) do
    nil
  end

  def call(conn, _) do
    assign(conn, :my_payment_lists, my_payment_lists(current_user(conn)))
  end

  @doc """
  Returns payment lists for the provided user.
  """
  @spec my_payment_lists(User | Nil) :: List
  def my_payment_lists(nil), do: []
  def my_payment_lists(current_user) do
    current_user
    |> get_user_payment_lists_query
    |> get_user_payment_lists
  end

  defp get_user_payment_lists_query(current_user) do
    from pl in PaymentList,
    left_join: pld in PaymentListDebitor,
    on: pl.id == pld.payment_list_id,
    where: pl.user_id == ^current_user.id,
    select: %{id: pl.id, user_id: pl.user_id, deputy_id: pl.deputy_id, title: pl.title, price_per_piece: pl.price_per_piece, number_of_debitors: count(pld.id)},
    order_by: [asc: pl.title],
    group_by: [pl.id, pl.user_id, pl.deputy_id, pl.title, pl.price_per_piece]
  end

  defp get_user_payment_lists(query) do
    query
    |> Repo.all
    |> Enum.map(fn(map) -> struct(PaymentList, map) end)
  end
end
