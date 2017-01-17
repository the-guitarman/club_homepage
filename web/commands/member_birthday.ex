defmodule ClubHomepage.MemberBirthday do
  @moduledoc """
  This module holds calculations around birthdays.
  """

  alias ClubHomepage.Repo
  alias ClubHomepage.User

  import Plug.Conn
  import Ecto.Query, only: [from: 2]
  import ClubHomepage.Extension.CommonMatch, only: [internal_user_name: 1]

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
    from(u in User, select: %{id: u.id, name: u.name, nickname: u.nickname, birthday: u.birthday, age_as_postgres_interval: fragment("date_trunc('year', age(birthday)) + interval '1 year'")}, where: fragment("? + date_trunc('year', age(?)) + interval '1 year' <= current_date + interval '1 day' * ?", u.birthday, u.birthday, ^days), order_by: [desc: u.birthday])
  end

  defp get_users(query) do
    Repo.all(query)
  end

  defp collect_birthdays([]), do: []
  defp collect_birthdays([user | users]) do
    collect_birthdays(users)
    |> collect_birthday(user)
  end

  defp collect_birthday(map, user) do
    age_in_years = calculate_user_age_in_years(user.age_as_postgres_interval)
    next_birthday_at = Timex.shift(user.birthday, years: age_in_years)
    key = date_key(next_birthday_at)
    name_with_age = "#{internal_user_name(user)} (#{age_in_years})"
    Keyword.put(map, key, [name_with_age | (map[key] || [])])
  end

  defp calculate_user_age_in_years(age_as_postgres_interval) do
    round(age_as_postgres_interval.months / 12)
  end

  defp date_key(%{day: day, month: month, year: year}) do
    String.to_atom("#{year}-#{month}-#{day}")
  end
end
