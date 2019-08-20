defmodule ClubHomepage.UserTest do
  use ClubHomepage.ModelCase

  alias ClubHomepage.User

  #import ClubHomepage.Factory

  @valid_attrs %{birthday: Timex.to_datetime({1988, 4, 17}, "UTC"), email: "mail@example.de", login: "my_login", name: "some content", password: "my name"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = User.changeset(%User{}, @valid_attrs)
    assert changeset.valid?
    assert Map.has_key?(changeset.changes, :active)
    assert Map.has_key?(changeset.changes, :roles)

    {:ok, user} = Repo.insert(changeset)

    assert user.active == false
    assert user.roles == "member"

    {:error, changeset} =
      User.changeset(%User{}, @valid_attrs)
      |> Repo.insert
    refute changeset.valid?
    assert changeset.errors[:login] == {"has already been taken", [constraint: :unique, constraint_name: "users_login_index"]}
    assert changeset.errors[:email] == nil

    valid_attrs = %{ @valid_attrs | login: "sdkfjdskjf"}
    {:error, changeset} =
      User.changeset(%User{}, valid_attrs)
      |> Repo.insert
    refute changeset.valid?
    assert changeset.errors[:login] == nil
    assert changeset.errors[:email] == {"has already been taken", [constraint: :unique, constraint_name: "users_email_index"]}
  end

  test "changeset with invalid attributes" do
    changeset = User.changeset(%User{}, @invalid_attrs)
    refute changeset.valid?
    assert changeset.errors[:birthday] == {"can't be blank", [validation: :required]}
    assert changeset.errors[:login] == {"can't be blank", [validation: :required]}
    assert changeset.errors[:email] == {"can't be blank", [validation: :required]}
    assert changeset.errors[:name] == {"can't be blank", [validation: :required]}

    changeset = User.changeset(%User{}, %{login: "abc"})
    refute changeset.valid?
    assert changeset.errors[:login] == {"should be at least %{count} character(s)", [count: 6, validation: :length, kind: :min, type: :string]}

    changeset = User.changeset(%User{}, %{login: "abcdefghijklmnopqrstu"})
    refute changeset.valid?
    assert changeset.errors[:login] == {"should be at most %{count} character(s)", [count: 20, validation: :length, kind: :max, type: :string]}

    changeset = User.changeset(%User{}, %{login: "$%&§^#~@€()[]"})
    refute changeset.valid?
    assert changeset.errors[:login] == {"has invalid format", [validation: :format]}

    changeset = User.changeset(%User{}, %{email: "mail[at]example_de"})
    refute changeset.valid?
    assert changeset.errors[:email] == {"has invalid format", [validation: :format]}

    changeset = User.changeset(%User{}, %{name: String.duplicate("a", 101)})
    refute changeset.valid?
    assert changeset.errors[:name] == {"should be at most %{count} character(s)", [count: 100, validation: :length, kind: :max, type: :string]}
  end
end
