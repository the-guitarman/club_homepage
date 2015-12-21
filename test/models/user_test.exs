defmodule ClubHomepage.UserTest do
  use ClubHomepage.ModelCase

  alias ClubHomepage.User

  @valid_attrs %{birthday: Timex.Date.from({1988, 4, 17}, :local), email: "mail@example.de", login: "my_login", name: "some content", password: "my name"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = User.changeset(%User{}, @valid_attrs)
    assert changeset.valid?
    refute Map.has_key?(changeset.changes, :active)
    refute Map.has_key?(changeset.changes, :roles)

    {:ok, user} = Repo.insert(changeset)

    assert user.active == true
    assert user.roles == "member"

    changeset = User.changeset(%User{}, @valid_attrs)
    refute changeset.valid?
    assert changeset.errors[:login] == "ist bereits vergeben"
    assert changeset.errors[:email] == "ist bereits vergeben"
  end

  test "changeset with invalid attributes" do
    changeset = User.changeset(%User{}, @invalid_attrs)
    refute changeset.valid?
    assert changeset.errors[:birthday] == "can't be blank"
    assert changeset.errors[:login] == "can't be blank"
    assert changeset.errors[:email] == "can't be blank"
    assert changeset.errors[:name] == "can't be blank"

    changeset = User.changeset(%User{}, %{login: "abc"})
    refute changeset.valid?
    assert changeset.errors[:login] == {"ist zu kurz (min. 6, max. 20 Zeichen)", [count: 6]}

    changeset = User.changeset(%User{}, %{login: "abcdefghijklmnopqrstu"})
    refute changeset.valid?
    assert changeset.errors[:login] == {"ist zu lang (min. 6, max. 20 Zeichen)", [count: 20]}

    changeset = User.changeset(%User{}, %{login: "$%&§^#~@€()[]"})
    refute changeset.valid?
    assert changeset.errors[:login] == "enthält ungültige Zeichen (gültig: 0-9 a-z . _ -)"

    changeset = User.changeset(%User{}, %{email: "mail[at]example_de"})
    refute changeset.valid?
    assert changeset.errors[:email] == "hat ein ungültiges Format"

    changeset = User.changeset(%User{}, %{name: String.duplicate("a", 101)})
    refute changeset.valid?
    assert changeset.errors[:name] == {"ist zu lang (max. 100 Zeichen)", [count: 100]}
  end
end
