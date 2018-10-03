defmodule ClubHomepage.Web.CurrentTeamTableData do
  @moduledoc """
  Checks wether there is a table for the given team available.
  """

  require Logger

  alias ClubHomepage.Match
  alias ClubHomepage.Team
  alias ClubHomepage.Repo
  alias ClubHomepage.Web.Localization

  import Ecto.Query, only: [from: 2]
  import ClubHomepage.Extension.CommonTimex

  @doc """
  Checks wether there is a table for the given team available. If true,
  it returns the html and an as at timestamp. Otherwise the response is
  an empty string.
  """
  @spec run(Plug.Conn, ClubHomepage.Team) :: {String, Integer}
  def run(%Plug.Conn{} = conn, %Team{} = team) do
    current_table(conn, team, team.fussball_de_team_rewrite, team.fussball_de_team_id)
  end

  defp current_table(conn, team, club_rewrite, team_id) when is_binary(club_rewrite) and is_binary(team_id) do
    team
    |> current_table_config_check()
    |> current_table_from_cache(team.current_table_html, team.current_table_html_at)
    |> current_table_language_check()
    |> current_table_browser_check(conn)
    |> current_table_scraper(club_rewrite, team_id)
    |> current_table_log_error(Mix.env(), club_rewrite, team_id)
    |> current_table_response(team)
    |> current_table_save_to_cache(team)
  end
  defp current_table(_, _, _, _), do: {nil, nil}

  defp current_table_config_check(%Team{} = team) do
    case team.fussball_de_show_current_table do
      true -> {:ok, team}
      _ -> {:error, :show_current_table_is_off, timestamp_now()}
    end
  end

  defp current_table_from_cache({:ok, team}, html, html_at) when is_binary(html) and not(is_nil(html_at)) do
    start_at =
      Timex.now()
      |> Timex.shift(hours: -2)
      |> to_timex_ecto_datetime()

    match =
      from(m in Match,
           where: m.team_id == ^team.id,
           where: m.start_at > ^start_at,
           order_by: [asc: m.start_at],
           limit: 1
      )
      |> Repo.one

    from_cache = {:from_cache, html, html_at}

    cond do
      match == nil -> from_cache
      match && is_past(match.start_at) -> from_cache
      match && is_today(match.start_at) && is_cache_fresh(match.start_at, html_at) -> from_cache
      true -> :cache_empty
    end
  end
  defp current_table_from_cache({:ok, _team}, html, html_at) when is_nil(html) or is_nil(html_at), do: :cache_empty
  defp current_table_from_cache({:error, _, _} = error, _, _), do: error

  defp current_table_language_check({:error, _, _} = error), do: error
  defp current_table_language_check({:from_cache, _, _} = result), do: result
  defp current_table_language_check(:cache_empty), do: {:ok, current_table_current_locale(), timestamp_now()}

  defp current_table_browser_check({:from_cache, _, _} = result, _conn), do: result
  defp current_table_browser_check(language_check, conn) do
    case language_check do
      {:ok, "de", _} ->
        case Browser.bot?(conn) || Browser.search_engine?(conn) do
          true -> {:error, :request_from_bot_or_search_engine, timestamp_now()}
          _ -> language_check
        end
      {:ok, language, timestamp_now} -> {:error, "'#{language}' is the wrong language.", timestamp_now}
      {:error, _, _} -> language_check
    end
  end

  defp current_table_current_locale do
    case Mix.env() do
      :test -> "de"
      _ -> Localization.current_locale()
    end
  end

  defp current_table_scraper({:from_cache, _, _} = result, _club_rewrite, _team_id), do: result
  defp current_table_scraper(browser_check, club_rewrite, team_id) do
    case browser_check do
      {:ok, "de", _} -> ExFussballDeScraper.Scraper.current_table(club_rewrite, team_id)
      {:error, _, _} -> browser_check
    end
  end

  defp replace_scraper_team_name(html, scraper_team_name, team) do
    String.replace(html, scraper_team_name, team.name)
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

  defp timex_to_datetime(timex) do
    timex
    |> Timex.to_datetime()
  end

  defp current_table_log_error({:from_cache, _, _} = result, _, _, _), do: result
  defp current_table_log_error(result, :test, _, _), do: result
  defp current_table_log_error(scraper_result, _env, club_rewrite, team_id) do
    case scraper_result do
      {:error, reason, timestamp_now} ->
        Logger.error("ExFussballDeScraper.Scraper.current_table(\"#{club_rewrite}\", \"#{team_id}\"): #{reason}, at: #{timestamp_to_local_timex(timestamp_now)}")
        scraper_result
      _ -> scraper_result
    end
  end

  defp current_table_response({:from_cache, html, html_at}, _team), do: {:ok, html, html_at}
  defp current_table_response(scraper_result, %Team{} = team) do
    case scraper_result do
      {:ok, %{team_name: team_name, current_table: html}, timestamp_now} ->
        {
          :ok,
          replace_scraper_team_name(html, team_name, team),
          timestamp_to_local_timex(timestamp_now)
        }
      {:error, _, _} -> scraper_result
    end
  end

  defp current_table_save_to_cache({:error, _, _} = response, _team), do: response
  defp current_table_save_to_cache({:ok, html, timex} = response, team) do
    team
    |> Team.changeset(%{
          "current_table_html" => html,
          "current_table_html_at" => timex_to_datetime(timex)
       })
    |> Repo.update()

    response
  end

  defp is_today(timex) do
    now = Timex.now
    timex.year == now.year && timex.month == now.month && timex.day == now.day
  end

  defp is_past(timex) do
    now = Timex.now
    (timex.year < now.year) ||
    (timex.year == now.year && timex.month < now.month) ||
    (timex.year == now.year && timex.month == now.month && timex.day < now.day)
  end

  defp is_cache_fresh(start_at, cache_from) do
    after_match =
      start_at
      |> Timex.shift(hours: 2)
    Timex.before?(after_match, cache_from)
  end
end
