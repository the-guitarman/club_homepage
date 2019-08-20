defmodule ClubHomepage.PermalinkTest do
  use ClubHomepage.ModelCase

  alias ClubHomepage.Permalink

  @valid_attrs %{destination_path: "some content", source_path: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Permalink.changeset(%Permalink{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Permalink.changeset(%Permalink{}, @invalid_attrs)
    refute changeset.valid?
  end
end
