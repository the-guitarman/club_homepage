defmodule ClubHomepage.MemberBirthdayTest do
  use ClubHomepage.ModelCase
  use ExUnit.Case
  doctest ClubHomepage.Web.MemberBirthday

  alias ClubHomepage.Web.MemberBirthday
  alias ClubHomepage.Repo
  alias ClubHomepage.User

  import ClubHomepage.Factory

  test "next_birthdays" do
    Repo.delete_all(User)
    assert MemberBirthday.next_birthdays() == []

    birthday =
      Timex.local
      |> Timex.shift(days: 7)
      |> Timex.shift(years: -20)
    _user = insert(:user, birthday: birthday)
    assert MemberBirthday.next_birthdays() == []

    birthday =
      Timex.local
      |> Timex.shift(days: 6)
      |> Timex.shift(years: -20)
    user2 = insert(:user, birthday: birthday)
    birthdays = MemberBirthday.next_birthdays()
    assert Enum.count(birthdays) == 1
    assert in_birthdays?(birthdays, user2, 20)

    birthday =
      Timex.local
      |> Timex.shift(days: 0)
      |> Timex.shift(years: -21)
    user3 = insert(:user, birthday: birthday)
    birthdays = MemberBirthday.next_birthdays()
    assert Enum.count(birthdays) == 2
    assert in_birthdays?(birthdays, user2, 20)
    assert in_birthdays?(birthdays, user3, 21)

    birthday =
      Timex.local
      |> Timex.shift(days: 1)
      |> Timex.shift(years: -22)
    user4 = insert(:user, birthday: birthday)
    birthdays = MemberBirthday.next_birthdays()
    assert Enum.count(birthdays) == 3
    assert in_birthdays?(birthdays, user2, 20)
    assert in_birthdays?(birthdays, user3, 21)
    assert in_birthdays?(birthdays, user4, 22)

    birthday =
      Timex.local
      |> Timex.shift(days: -1)
      |> Timex.shift(years: -23)
    user5 = insert(:user, birthday: birthday)
    birthdays = MemberBirthday.next_birthdays()
    assert Enum.count(birthdays) == 3
    assert in_birthdays?(birthdays, user2, 20)
    assert in_birthdays?(birthdays, user3, 21)
    assert in_birthdays?(birthdays, user4, 22)
    refute in_birthdays?(birthdays, user5, 23)

    date_keys = Keyword.keys(birthdays)
    dates = Enum.map(date_keys,
      fn(date_key) ->
        {:ok, date} = Timex.parse(Atom.to_string(date_key), "%Y-%m-%d", :strftime)
        date
      end
    )
    dates_sorted = Enum.sort(dates,
      fn(date1, date2) ->
        Timex.compare(date1, date2) == -1
      end
    )
    assert dates == dates_sorted
  end

  defp in_birthdays?(birthdays, user, age) do
    Keyword.keys(birthdays)
    |> Enum.any?(
      fn(key) ->
        Enum.any?(birthdays[key], fn(user_string) -> "#{user.name} (#{age})" == user_string end)
      end)
  end
end
