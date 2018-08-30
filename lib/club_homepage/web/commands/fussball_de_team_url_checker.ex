defmodule ClubHomepage.Web.FussballDeTeamUrlChecker do
  @moduledoc """
  Checks a fussball.de url and grabs some parameters from it.
  """

  import Ecto.Changeset, only: [get_change: 2, put_change: 3, add_error: 3]

  @doc """
  It checks the given url. If it's a fussball.de url but there's a
  parser error, it will add an error to the url field. Otherwise is takes
  the parameters an fill them into the configured fields.
  """
  @spec run(Ecto.Changeset, Atom|String, Atom|String, Atom|String) :: Ecto.Changeset
  def run(changeset, team_url_field, team_rewrite_field, team_id_field) do
    case get_change(changeset, convert_to_atom(team_url_field)) do
      nil -> clean_team_fields(changeset, team_rewrite_field, team_id_field)
      url -> set_team_fields(changeset, team_url_field, team_rewrite_field, team_id_field, ExFussballDeScraper.Url.parse(url))
    end
  end

  defp set_team_fields(changeset, _, team_rewrite_field, team_id_field, {:ok, team_rewrite, team_id}) do
    changeset
    |> put_change(convert_to_atom(team_rewrite_field), team_rewrite)
    |> put_change(convert_to_atom(team_id_field), team_id)
  end
  defp set_team_fields(changeset, team_url_field, _, _, {:error, reason}) do
    changeset
    |> add_error(convert_to_atom(team_url_field), convert_to_string(reason))
  end

  defp clean_team_fields(changeset, team_rewrite_field, team_id_field) do
    changeset
    |> put_change(convert_to_atom(team_rewrite_field), nil)
    |> put_change(convert_to_atom(team_id_field), nil) 
  end

  defp convert_to_atom(atom) when is_atom(atom), do: atom
  defp convert_to_atom(text) when is_bitstring(text) do
    String.to_atom(text)
  end

  defp convert_to_string(text) when is_binary(text), do: text
  defp convert_to_string(atom) when is_atom(atom) do
    Atom.to_string(atom)
  end
end
