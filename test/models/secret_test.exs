defmodule ClubHomepage.SecretTest do
  use ClubHomepage.ModelCase

  alias ClubHomepage.Secret

  @valid_attrs %{}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Secret.changeset(%Secret{}, @valid_attrs)
    assert changeset.valid?

    {:ok, secret} = Repo.insert(changeset)
    expires_at = Timex.DateTime.local |> Timex.add(Timex.Time.to_timestamp(7, :days))

    assert String.length(secret.key) == 22
    assert secret.expires_at.day == expires_at.day
    assert secret.expires_at.month == expires_at.month
    assert secret.expires_at.year == expires_at.year
  end
end
