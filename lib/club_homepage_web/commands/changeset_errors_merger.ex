defmodule ClubHomepageWeb.ChangesetErrorsMerger do
  @moduledoc """
  A helper module to merge errors of two changesets into one changeset.
  """

  alias Ecto.Changeset

  @doc """
  Merges the errors of two given Ecto.Changeset's together, appends the result to the first changeset and returns it.
  """
  @spec merge(Changeset.t, Changeset.t) :: Changeset.t
  def merge(changeset1, changeset2) do
    errors = Keyword.merge(changeset2.errors, changeset1.errors)
    changeset = %Ecto.Changeset{changeset1 | errors: errors}

    case Enum.count(changeset.errors) do
      0 -> changeset
      _ -> %Changeset{changeset | valid?: false}
    end
  end
end
