defmodule ClubHomepage.Web.PermalinkGenerator  do
  @moduledoc """
  Generates permalinks to redirect paths with old slugs to new ones. 
  """

  import Ecto.Query, only: [from: 2]

  alias ClubHomepage.Permalink
  alias ClubHomepage.Repo

  @doc """
  In the easiest form it takes a string and returns the slug. 

  ## Example usage
      iex> query = from(p in ClubHomepage.Permalink, select: count(p.id))
      iex> 0 == Repo.one(query)
      true
      iex> ClubHomepage.Web.PermalinkGenerator.run("old-slug", "new-slug", :teams)
      iex> 1 == Repo.one(query)
      true
      iex> permalink = Repo.one(ClubHomepage.Permalink)
      iex> "/teams/old-slug" == permalink.source_path
      true
      iex> "/teams/new-slug" == permalink.destination_path
      true
  """
  @spec run(String, String, String | Atom) :: String
  @spec run(Ecto.Changeset, String | Atom) :: Ecto.Changeset
  def run(source_slug, destination_slug, path_prefix) do
    create_permalink(source_slug, destination_slug, path_prefix)
  end
  def run(changeset, path_prefix) do
    changeset
    |> slug_from_model
    |> slug_from_changes
    |> create_permalink_from_changeset(path_prefix)
  end

  defp slug_from_model(%{data: model} = changeset) do
    case model.slug do
      nil  -> {:error, changeset}
      slug -> {:ok, changeset, slug}
    end
  end 
  
  defp slug_from_changes({:error, %{changes: changes} = changeset}) do
    case changes[:slug] do
      nil  -> {:error, changeset, nil}
      slug -> {:error, changeset, slug}
    end
  end
  defp slug_from_changes({:ok, %{changes: changes} = changeset, model_slug}) do
    case changes[:slug] do
      nil  -> {:error, changeset, nil}
      slug -> {:ok, changeset, model_slug, slug}
    end
  end

  defp create_permalink_from_changeset({:error, changeset, nil}, _path_prefix), do: changeset
  defp create_permalink_from_changeset({:error, changeset, changes_slug}, path_prefix) do
    create_path(changes_slug, path_prefix)
    |> delete_permalink()
    changeset
  end
  defp create_permalink_from_changeset({:ok, changeset, model_slug, changes_slug}, path_prefix) do
    case model_slug == changes_slug do
      true  -> nil
      false -> create_permalink(model_slug, changes_slug, path_prefix)
    end
    changeset
  end

  defp create_permalink(source_slug, destination_slug, path_prefix) do
    source_path = create_path(source_slug, path_prefix)
    destination_path = create_path(destination_slug, path_prefix)
    delete_permalink(source_path)
    delete_permalink(destination_path)
    changeset = Permalink.changeset(%Permalink{}, %{source_path: source_path, destination_path: destination_path})
    Repo.insert(changeset)
  end

  defp delete_permalink(path) do
    from(p in Permalink, where: p.source_path == ^path)
    |> Repo.delete_all
  end

  defp create_path(slug, path_prefix) do
    "/#{clean_slashes(path_prefix)}/#{clean_slashes(slug)}"
  end

  defp clean_slashes(text) when is_atom(text) do
    clean_slashes(Atom.to_string(text))
  end
  defp clean_slashes(text) when is_bitstring(text) do
    without_trailing_slashes = Regex.replace(~r{^/|/$}, text, "")
    Regex.replace(~r{//}, without_trailing_slashes, "/")
  end
end
