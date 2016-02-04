defmodule ClubHomepage.NewsTest do
  use ClubHomepage.ModelCase

  alias ClubHomepage.News

  @valid_attrs %{body: "This is the message.", public: true, subject: "Some Subject"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = News.changeset(%News{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = News.changeset(%News{}, @invalid_attrs)
    refute changeset.valid?
    assert changeset.model.public     == false
    assert changeset.changes[:public] == nil
    assert changeset.errors[:public]  == nil
    assert changeset.errors[:subject] == "can't be blank"
    assert changeset.errors[:body]    == "can't be blank"
  end
end
