defmodule ClubHomepage.MyPaymentLists do
  @moduledoc """
  This module holds calculations around birthdays.
  """

  alias ClubHomepage.Repo
  alias ClubHomepage.PaymentList
  alias ClubHomepage.User

  import Plug.Conn
  import Ecto.Query, only: [from: 2]
  import ClubHomepage.Extension.CommonMatch, only: [internal_user_name: 1]
  import ClubHomepage.Auth

  def init(_opts) do
    nil
  end

  def call(conn, _) do
    assign(conn, :my_payment_lists, my_payment_lists(current_user(conn)))
  end

  @doc """
  Returns the birthdays of the next days.
  """
  @spec my_payment_lists(User | Nil) :: List
  def my_payment_lists(nil), do: []
  def my_payment_lists(current_user) do
    current_user
    |> get_user_payment_lists_query
    |> get_user_payment_lists
  end

  defp get_user_payment_lists_query(current_user) do
    from(bl in PaymentList, where: bl.user_id == ^current_user.id or bl.deputy_id == ^current_user.id, preload: [:user, :deputy, :debitors])
  end

  defp get_user_payment_lists(query) do
    Repo.all(query)
  end
end
