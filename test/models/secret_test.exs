defmodule ClubHomepage.SecretTest do
  use ClubHomepage.ModelCase

  alias ClubHomepage.Secret

  @valid_attrs %{}
  #@invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Secret.changeset(%Secret{}, @valid_attrs)
    assert changeset.valid?

    {:ok, secret} = Repo.insert(changeset)
    expires_at = Timex.local |> Timex.add(Timex.Duration.from_days(7))

    assert String.length(secret.key) == 22
    assert secret.expires_at.day == expires_at.day
    assert secret.expires_at.month == expires_at.month
    assert secret.expires_at.year == expires_at.year
  end

  test "changeset with invalid email" do
    valid_attrs = Map.put(@valid_attrs, :email, "test[at]example_com")

    changeset = Secret.changeset(%Secret{}, valid_attrs)
    assert not changeset.valid?
    assert changeset.errors[:email] == {"has invalid format", []}
  end

  test "changeset with valid email" do
    valid_attrs = Map.put(@valid_attrs, :email, "test@example.com")

    changeset = Secret.changeset(%Secret{}, valid_attrs)
    assert changeset.valid?
  end
end
