defmodule ClubHomepageWeb.NewTeamMatchesData do
  @moduledoc """
  Checks wether there are new matches for the given team available.
  """

  require Logger
  alias ClubHomepage.Repo
  alias ClubHomepage.Match
  alias ClubHomepage.Team

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
    |> last_new_matches_update_check()
    |> new_matches_browser_check(conn)
    |> get_new_matches(club_rewrite, team_id)
    |> new_matches_log_error(Mix.env(), club_rewrite, team_id)
    |> new_matches_filter(team)
    |> home_match_detection()
    |> save_last_new_matches_check_at(team)
  end
  defp new_matches(_conn, _team, _, _), do: {:error, :no_club_rewrite_or_team_id_available, timestamp_now()}

  defp new_matches_config_check(team) do
    case team.fussball_de_show_next_matches do
      true -> {:ok, team}
      _ -> {:error, :show_next_matches_is_off, timestamp_now()}
    end
  end

  defp last_new_matches_update_check({:error, _, _} = error), do: error
  defp last_new_matches_update_check({:ok, team}) do
    case team.fussball_de_last_next_matches_check_at do
      nil -> :ok
      last_update_at -> update_new_matches_now(last_update_at)
    end
  end

  defp update_new_matches_now(last_update_at) do
    case is_today(last_update_at) do
      true -> {:error, :next_matches_check_done_today, timestamp_now()}
      _ -> :ok
    end
  end

  defp new_matches_browser_check({:error, _, _} = error, _conn), do: error
  defp new_matches_browser_check(:ok, conn) do
    case Browser.bot?(conn) || Browser.search_engine?(conn) do
      true -> {:error, :request_from_bot_or_search_engine, timestamp_now()}
      _ -> :ok
    end
  end

  defp get_new_matches({:error, _, _} = error, _club_rewrite, _team_id), do: error
  defp get_new_matches(:ok, club_rewrite, team_id) do
    ExFussballDeScraper.Scraper.next_matches(club_rewrite, team_id)
  end

  defp new_matches_log_error({:ok, _, _} = result, _env, _club_rewrite, _team_id), do: result
  defp new_matches_log_error({:error, _, _} = error, :test, _club_rewrite, _team_id), do: error
  defp new_matches_log_error({:error, reason, created_at_timestamp} = error, _env, club_rewrite, team_id) do
    Logger.error("ExFussballDeScraper.Scraper.next_matches(\"#{club_rewrite}\", \"#{team_id}\"): #{reason}, at: #{timestamp_to_local_timex(created_at_timestamp)}")
    error
  end

  defp new_matches_filter({:error, _, _} = error, _team), do: error
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

  defp home_match_detection({:error, _, _} = error), do: error
  defp home_match_detection({:ok, result, created_at_timestamp}) do
    new_matches_extended =
      result.matches
      |> Enum.map(fn(match) -> Map.put(match, :home_match, match.home == result.team_name) end)
    {:ok, Map.put(result, :matches, new_matches_extended), created_at_timestamp}
  end

  defp save_last_new_matches_check_at({:error, _, _} = error, _team), do: error
  defp save_last_new_matches_check_at({:ok, _, _} = result, team) do
    team
    |> Team.changeset(%{"fussball_de_last_next_matches_check_at" => Timex.now() |> Timex.to_datetime()})
    |> Repo.update()

    result
  end

  defp timestamp_to_local_timex(timestamp) do
    timestamp
    |> Timex.from_unix()
    |> Timex.Timezone.convert(Timex.Timezone.Local.lookup())
  end

  defp timestamp_now() do
    Timex.local()
    |> Timex.to_unix()
  end

  defp is_today(timex) do
    now = Timex.now
    timex.year == now.year && timex.month == now.month && timex.day == now.day
  end
end
