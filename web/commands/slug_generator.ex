defmodule ClubHomepage.SlugGenerator  do
  @moduledoc """
    Generates an url slug from a given string or a changeset field. 
  """

  import Ecto.Changeset, only: [get_change: 2, put_change: 3]

  @doc """
  In the easiest form it takes a string and returns the slug. 

  ## Example usage
      iex> slug = ClubHomepage.SlugGenerator.run("This is my    team without ß in the name.")
      iex> slug === "this-is-my-team-without-ss-in-the-name"
      true

      iex> changeset = 
      ...>   ClubHomepage.Team.changeset(%ClubHomepage.Team{}, %{name: "This is another    team without ß in the name", slug: nil})
      ...>   |> ClubHomepage.SlugGenerator.run(:name, :slug)
      iex> changeset.changes.slug == "this-is-another-team-without-ss-in-the-name"
      true
  """
  @spec run(String) :: String
  @spec run(Ecto.Changeset, String, String) :: Ecto.Changeset
  def run(phrase), do: slugify(phrase)
  def run(changeset, from_field, to_field) do
    case get_change(changeset, convert_to_atom(from_field)) do
      nil   -> changeset
      value -> put_change(changeset, convert_to_atom(to_field), slugify(value))
    end
  end

  defp convert_to_atom(text) when is_atom(text), do: text
  defp convert_to_atom(text) when is_bitstring(text) do
    String.to_atom(text)
  end

  defp extract_field_value({_, value}) do
    value
  end

  defp slugify(nil = phrase), do: phrase
  defp slugify(phrase) do
    Slugger.slugify_downcase(phrase)
  end
end
