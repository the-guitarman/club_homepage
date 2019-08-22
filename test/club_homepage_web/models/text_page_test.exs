defmodule ClubHomepage.TextPageTest do
  use ClubHomepage.ModelCase

  alias ClubHomepage.TextPage

  import ClubHomepage.Factory

  @valid_attrs %{key: "some content", text: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = TextPage.changeset(%TextPage{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = TextPage.changeset(%TextPage{}, @invalid_attrs)
    refute changeset.valid?
  end

  test "edit a text_page" do
    text_page1 = insert(:text_page)
    text_page2 = insert(:text_page)

    changeset = TextPage.changeset(text_page2, %{key: "new text_page key"})
    {:ok, text_page} = Repo.update(changeset)

    assert text_page.key == "new text_page key"

    changeset = TextPage.changeset(text_page2, %{key: text_page1.key})
    {:error, changeset} = Repo.update(changeset)
    refute changeset.valid?
    assert changeset.errors[:key] == {"has already been taken", [constraint: :unique, constraint_name: "text_pages_key_index"]}
  end
end
