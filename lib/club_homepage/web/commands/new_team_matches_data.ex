defmodule ClubHomepage.Web.NewTeamMatchesData do
  @moduledoc """
  Checks wether there are new matches for the given team available.
  """

  require Logger
  alias ClubHomepage.Repo
  alias ClubHomepage.Match
  alias ClubHomepage.Team
  alias ClubHomepage.Web.Localization

  import Ecto.Query, only: [from: 2]

  @doc """
  Checks wether there new matches for the given team available. If true,
  it returns the new matches as map. Otherwise the response is nil.
  """
  @spec run(Plug.Conn, ClubHomepage.Team) :: Map | nil
  def run(conn, team) do
    new_matches(conn, team, team.fussball_de_team_rewrite, team.fussball_de_team_id)
  end


  defp new_matches(conn, team, club_rewrite, team_id) when is_binary(club_rewrite) and is_binary(team_id) do
    team
    |> new_matches_config_check()
    |> get_new_matches(club_rewrite, team_id)
    |> new_matches_log_error(Mix.env(), club_rewrite, team_id)
    |> new_matches_filter(team)
  end
  defp new_matches, do: nil

  defp new_matches_config_check(%Team{} = team) do
    case team.fussball_de_show_next_matches do
      true -> :ok
      _ -> {:error, :show_next_matches_is_off}
    end
  end

  defp get_new_matches({:error, _} = error, _club_rewrite, _team_id), do: error
  defp get_new_matches(:ok, club_rewrite, team_id) do
    ExFussballDeScraper.Scraper.next_matches(club_rewrite, team_id)
  end

  defp new_matches_log_error({:error, reason, created_at_timestamp} = error, _env, club_rewrite, team_id) do
    Logger.error("ExFussballDeScraper.Scraper.next_matches(\"#{club_rewrite}\", \"#{team_id}\"): #{reason}, at: #{timestamp_to_local_timex(created_at_timestamp)}")
    error
  end
  defp new_matches_log_error({:ok, _, _} = result, _env, club_rewrite, team_id), do: result

  defp new_matches_filter({:error, reason, created_at_timestamp} = error, _team), do: error
  defp new_matches_filter({:ok, result, created_at_timestamp}, team) do
    new_matches_map_filtered =
      result.matches
      |> extract_new_match_ids()
      |> find_saved_match_ids(team)
      |> remove_found_matches()
    {:ok, Map.put(result, :matches, new_matches_map_filtered), created_at_timestamp}
  end

  defp extract_new_match_ids(new_matches_map) do
    {new_matches_map, Enum.map(new_matches_map, &(&1.id))}
  end

  defp find_saved_match_ids({new_matches_map, new_matches_ids}, team) do
    found_matches_ids =
      from(
        m in Match,
        where: m.team_id == ^team.id,
        where: m.fussball_de_match_id in ^new_matches_ids
      )
      |> Repo.all()
      |> Enum.map(&(&1.fussball_de_match_id))
    {new_matches_map, found_matches_ids}
  end

  defp remove_found_matches({new_matches_map, found_matches_ids}) do
    new_matches_map
    |> Enum.filter(fn(match) -> not(Enum.member?(found_matches_ids, match.id)) end)
  end

  defp timestamp_to_local_timex(timestamp) do
    timestamp
    |> Timex.from_unix()
    |> Timex.Timezone.convert(Timex.Timezone.Local.lookup())
  end
end
