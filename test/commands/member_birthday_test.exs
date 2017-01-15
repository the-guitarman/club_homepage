defmodule ClubHomepage.MemberBirthdayTest do
  use ClubHomepage.ModelCase
  use ExUnit.Case
  doctest ClubHomepage.MemberBirthday

  alias ClubHomepage.MemberBirthday
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
    assert Enum.any?(birthdays, fn(el) -> el.id == user2.id end)

    birthday =
      Timex.local
      |> Timex.shift(days: 0)
      |> Timex.shift(years: -20)
    user3 = insert(:user, birthday: birthday)
    birthdays = MemberBirthday.next_birthdays()
    assert Enum.count(birthdays) == 2
    assert Enum.any?(birthdays, fn(el) -> el.id == user2.id end)
    assert Enum.any?(birthdays, fn(el) -> el.id == user3.id end)

    birthday =
      Timex.local
      |> Timex.shift(days: 1)
      |> Timex.shift(years: -20)
    user4 = insert(:user, birthday: birthday)
    birthdays = MemberBirthday.next_birthdays()
    assert Enum.count(birthdays) == 3
    assert Enum.any?(birthdays, fn(el) -> el.id == user2.id end)
    assert Enum.any?(birthdays, fn(el) -> el.id == user3.id end)
    assert Enum.any?(birthdays, fn(el) -> el.id == user4.id end)

    birthday =
      Timex.local
      |> Timex.shift(days: -1)
      |> Timex.shift(years: -20)
    user5 = insert(:user, birthday: birthday)
    birthdays = MemberBirthday.next_birthdays()
    assert Enum.count(birthdays) == 3
    assert Enum.any?(birthdays, fn(el) -> el.id == user2.id end)
    assert Enum.any?(birthdays, fn(el) -> el.id == user3.id end)
    assert Enum.any?(birthdays, fn(el) -> el.id == user4.id end)
    refute Enum.any?(birthdays, fn(el) -> el.id == user5.id end)

    assert Enum.map(birthdays, fn(birthday) -> birthday.id end) == [user3.id, user4.id, user2.id]
  end
end
