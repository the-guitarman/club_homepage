defmodule ClubHomepage.Web.ChangesetErrorsMerger do
  alias Ecto.Changeset

  def merge(changeset1, changeset2) do
    errors = Keyword.merge(changeset2.errors, changeset1.errors)
    changeset = %Ecto.Changeset{changeset1 | errors: errors}

    case Enum.count(changeset.errors) do
      0 -> changeset
      _ -> %Changeset{changeset | valid?: false}
    end
  end
end
