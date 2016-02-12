defmodule ClubHomepage.SlugGenerator  do
  @moduledoc """
    Generates an url slug string from a given string or a changeset field. 
  """

  import Ecto.Changeset, only: [fetch_field: 2, put_change: 3]

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
  def run(phrase), do: generate(phrase)
  def run(changeset, from_field, to_field) do
    value = 
      extract_field_value(fetch_field(changeset, from_field))
      |> generate
    put_change(changeset, to_field, value)
  end

  defp extract_field_value({_, value}) do
    value
  end

  defp generate(nil = phrase), do: phrase
  defp generate(phrase) do
    Slugger.slugify_downcase(phrase)
  end
end
