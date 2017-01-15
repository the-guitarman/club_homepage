defmodule ClubHomepage.MemberBirthday do
  @moduledoc """
  This module holds calculations around birthdays.
  """

  alias ClubHomepage.Repo
  alias ClubHomepage.User

  import Plug.Conn
  import Ecto.Query, only: [from: 2]

  def init(_opts) do
    nil
  end

  def call(conn, _) do
    assign(conn, :birthdays, next_birthdays)
  end

  @doc """
  Returns the birthdays of the next days.
  """
  @spec next_birthdays() :: List
  @spec next_birthdays(Integer) :: List
  def next_birthdays(days_from_now \\ 7) do
    days_from_now
    |> get_users_query
    |> get_users
    |> collect_birthdays
  end

  defp get_users_query(days) do
    from(u in User, where: fragment("? + date_trunc('year', age(?)) + interval '1 year' <= current_date + interval '1 day' * ?", u.birthday, u.birthday, ^days))
  end

  defp get_users(query) do
    Repo.all(query)
  end

  defp collect_birthdays(users) do
    users
  end
end
