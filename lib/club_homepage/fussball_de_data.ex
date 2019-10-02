defmodule ClubHomepage.FussballDeData do
  @moduledoc """
  The Accounts context.
  """

  require Logger

  import Ecto.Query, warn: false

  alias ClubHomepage.Repo
  #alias ClubHomepage.Extension.CommonTimex
  alias ClubHomepageWeb.Localization

  alias ClubHomepage.Team
  alias ClubHomepage.Season

  alias ClubHomepage.FussballDeData.SeasonTeamTable




  @doc """
  Creates or updates the current season team table for the given team or
  finds the season team table for the given team and season.
  """
  @spec create_or_update_or_find_current_team_table(Team, Season) :: {:created_or_updated, SeasonTeamTable} | {:error, Atom.t, non_neg_integer()}
  def create_or_update_or_find_current_team_table(%Team{} = team, %Season{} = season) do
    case current_locale() do
      "de" ->
        team
        |> create_or_update_current_team_table()
        |> get_this_season_team_table(team, season)
      _ -> nil
    end
  end

  defp get_this_season_team_table(nil, team, season) do
    get_season_team_table(team, season)
  end
  defp get_this_season_team_table(%Ecto.Changeset{} = _changeset, team, season) do
    get_season_team_table(team, season)
  end
  defp get_this_season_team_table(season_team_table, _team, season) do
    case season_team_table.season_id == season.id do
      true -> season_team_table
      _ -> nil
    end
  end




  @doc """
  Returns the current team table of the season.
  """
  @spec get_season_team_table(Team, Season) :: SeasonTeamTable | nil
  def get_season_team_table(%Team{} = team, %Season{} = season) do
    {team, season}
    |> show_season_team_table_for_team_check()
    |> show_season_team_table_team_config_check()
    |> find_season_team_table()
    |> get_html_from_season_team_table()
    |> log_get_season_team_table_error(team, season, Mix.env())
  end

  defp show_season_team_table_for_team_check({team, season}) do
    case team.fussball_de_show_current_table do
      true -> {:ok, team, season}
      _ -> {:error, :show_current_table_is_off, timestamp_now()}
    end
  end

  defp show_season_team_table_team_config_check({:ok, team, season}) do
    case team.fussball_de_team_rewrite == nil or team.fussball_de_team_id == nil do
      true -> {:error, :show_current_table_no_team_config, timestamp_now()}
      _ -> {:ok, team, season}
    end
  end
  defp show_season_team_table_team_config_check(error), do: error

  defp find_season_team_table({:ok, team, season}) do
    # updated_at =
    #   Timex.now()
    #   |> Timex.shift(hours: -2)
    #   |> CommonTimex.to_timex_ecto_datetime()

    season_team_table =
      from(stt in SeasonTeamTable,
           where: stt.team_id == ^team.id,
           where: stt.season_id == ^season.id
           #where: stt.updated_at > ^updated_at
      )
      |> Repo.one()

    {:ok, team, season, season_team_table}
  end
  defp find_season_team_table(error), do: error

  defp get_html_from_season_team_table({:ok, _team, _season, nil}) do
    {:error, :no_season_team_table_found, timestamp_now()}
  end
  defp get_html_from_season_team_table({:ok, _team, _season, season_team_table}) do
    case season_team_table.html do
      "" -> {:error, :empty_season_team_table_found, timestamp_now()}
      nil -> {:error, :empty_season_team_table_found, timestamp_now()}
      _html -> {:ok, season_team_table}
    end
  end
  defp get_html_from_season_team_table(error), do: error

  defp log_get_season_team_table_error({:ok, season_team_table}, _team, _season, _env), do: season_team_table
  defp log_get_season_team_table_error({:error, reason, timestamp}, team, season, env) when is_atom(env) and env != :test do
    Logger.error("#{timestamp_to_local_timex(timestamp)}: ClubHomepage.FussballDeData.get_season_team_table(team.id:\"#{team.id}\", season.id:\"#{season.id}\"), #{reason}")
    nil
  end
  defp log_get_season_team_table_error(_error, _team, _season, _env), do: nil





  @doc """
  Grabs the current team table from fussball.de and creates or updates the season team table of the given team.
  """
  @spec create_or_update_current_team_table(Team) :: { String.t, non_neg_integer() | {:error, term()} } | { nil, nil }
  def create_or_update_current_team_table(%Team{} = team) do
    team
    |> current_table_config_check()
    |> current_table_team_config_check()
    |> current_table_scraper()
    |> save_scraper_response(team)
    |> log_update_current_team_table_error(team, Mix.env())
  end
  def create_or_update_current_team_table({:error, _, _}), do: {nil, nil}

  defp current_table_config_check(%Team{} = team) do
    case team.fussball_de_show_current_table do
      true -> {:ok, team}
      _ -> {:error, :show_current_table_is_off, timestamp_now()}
    end
  end

  defp current_table_team_config_check({:ok, team}) do
    case team.fussball_de_team_rewrite == nil or team.fussball_de_team_id == nil do
      true -> {:error, :show_current_table_no_team_config, timestamp_now()}
      _ -> {:ok, team}
    end
  end
  defp current_table_team_config_check(error), do: error

  defp current_table_scraper({:ok, team}) do
    ExFussballDeScraper.Scraper.current_table(team.fussball_de_team_rewrite, team.fussball_de_team_id)
  end
  defp current_table_scraper(error), do: error |> IO.inspect()

  defp save_scraper_response({:ok, %{team_name: team_name, season: season_name, current_table: html}, _timestamp}, team) do
    html = replace_scraper_team_name(html, team_name, team.name)
    {:ok, season} = Season.find_or_create(%{name: season_name})
    case SeasonTeamTable.create_or_update(%{season_id: season.id, team_id: team.id}, %{html: html}) do
      {:ok, season_team_table} -> {:ok, season_team_table}
      {:error, _changeset} -> {:error, :creation_or_update_failed, timestamp_now()}
    end
  end
  defp save_scraper_response(error, _team), do: error

  defp replace_scraper_team_name(html, scraper_team_name, team_name) do
    String.replace(html, scraper_team_name, team_name)
  end

  defp log_update_current_team_table_error({:ok, season_team_table}, _team, _env), do: season_team_table
  defp log_update_current_team_table_error({:error, reason, timestamp}, team, env) when is_atom(env) and env != :test do
    Logger.error("#{timestamp_to_local_timex(timestamp)}: ClubHomepage.FussballDeData.update_current_team_table(team.id:\"#{team.id}\"), #{reason}")
    nil
  end
  defp log_update_current_team_table_error(_error, _team, _env), do: nil









  defp timestamp_now() do
    Timex.local()
    |> Timex.to_unix()
  end

  defp timestamp_to_local_timex(timestamp) do
    timestamp
    |> Timex.from_unix()
    |> Timex.Timezone.convert(Timex.Timezone.Local.lookup())
  end

  @doc """
  Returns the current locale.

  ## Example usage
  iex> ClubHomepage.FussballDeData.current_locale()
  "de"
  """
  def current_locale() do
    case Mix.env() do
      :test -> "de"
      _ -> Localization.current_locale()
    end
  end
end
