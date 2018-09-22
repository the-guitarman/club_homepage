defmodule ClubHomepage.Web.NewTeamMatchesData do
  @moduledoc """
  Checks wether there are new matches for the given team available.
  """

  require Logger
  alias ClubHomepage.Team
  alias ClubHomepage.Web.Localization

  @doc """
  Checks wether there new matches for the given team available. If true,
  it returns the new matches as map. Otherwise the response is nil.
  """
  @spec run(Plug.Conn, ClubHomepage.Team) :: Map | nil
  def run(conn, team) do
    new_matches(conn, team, team.fussball_de_team_rewrite, team.fussball_de_team_id)
  end


  defp new_matches(conn, team, club_rewrite, team_id) when is_binary(club_rewrite) and is_binary(team_id) do
    nil
  end
  defp new_matches, do: nil
end
