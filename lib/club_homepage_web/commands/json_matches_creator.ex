defmodule ClubHomepageWeb.JsonMatchesCreator do
  @moduledoc """
  Creates matches from a json.
  """

  alias ClubHomepageWeb.JsonMatchesValidator
  alias ClubHomepage.Competition
  alias ClubHomepage.Match
  alias ClubHomepage.OpponentTeam
  alias ClubHomepage.Repo
  alias ClubHomepage.Season

  @doc """
  Creates matches from a valid changeset returned by JsonMatchesValidator. 
  """
  #@spec run(Ecto.Changeset.t, String.t) :: Integer.t
  def run(changeset, json_field) do
    params     = changeset.params
    team_id    = params["team_id"]
    map = 
      case JSON.decode(params[json_field]) do
        {:ok, map} -> map
        {:error, _} -> %{"team_name" => "", "matches" => []}
      end
    create_matches(team_id, map["matches"], map["team_name"], map["season"])
  end

  defp create_matches(team_id, matches_maps, team_name, season_name, records_count \\ 0)
  defp create_matches(_team_id, [], _team_name, _season_name, _records_count), do: 0
  defp create_matches(team_id, [match_map | matches_maps], team_name, season_name, records_count) do
    records_count + create_match(team_id, match_map, team_name, season_name) + create_matches(team_id, matches_maps, team_name, season_name)
  end 

  defp create_match(team_id, match_map, team_name, season_name) do
    map =
      match_map
      |> Map.put("competition_id", competition_id(match_map["competition"]))
      |> Map.put("season_id", season_id(season_name))
      |> Map.put("team_id", team_id)
      |> Map.put("opponent_team_id", opponent_team_id(opponent_team_name(team_name, match_map)))
      |> Map.put("start_at", parse_start_at(match_map["start_at"]))
      |> Map.put("home_match", home_match(team_name, match_map))
      |> Map.put("json_creation", true)
      |> Map.put("fussball_de_match_id", match_map["id"])
    changeset = Match.changeset(%Match{}, map)
    insert_valid_match(changeset)
  end

  defp season_id(season_name) do
    season = find_or_create_season(season_name)
    season.id
  end

  defp find_or_create_season(name) do
    case Repo.get_by(Season, name: name) do
      nil -> create_season(name)
      season -> season
    end
  end

  defp create_season(name) do
    changeset = Season.changeset(%Season{}, %{name: name})
    {:ok, season} = Repo.insert(changeset)
    season
  end

  defp parse_start_at(value) do
    case JsonMatchesValidator.to_timex_date_format(value) do
      {:ok, datetime} -> datetime
      {:error, _error} -> nil
    end
  end

  defp home_match(team_name, match_map) do
    match_map["home"] == team_name
  end

  defp competition_id(name) do
    competition = find_or_create_competition(name)
    competition.id
  end

  defp find_or_create_competition(name) do
    case Repo.get_by(Competition, name: name) do
      nil -> create_competition(name)
      competition -> competition
    end
  end

  defp create_competition(name) do
    changeset = Competition.changeset(%Competition{}, %{name: name, matches_need_decition: false})
    {:ok, competition} = Repo.insert(changeset)
    competition
  end

  defp opponent_team_name(team_name, match_map) do
    case home_match(team_name, match_map) do
      true  -> match_map["guest"]
      false -> match_map["home"]
    end
  end

  defp opponent_team_id(name) do
    opponent_team = find_or_create_opponent_team(name)
    opponent_team.id
  end

  defp find_or_create_opponent_team(name) do
    case Repo.get_by(OpponentTeam, name: name) do
      nil -> create_opponent_team(name)
      opponent_team -> opponent_team
    end
  end

  defp create_opponent_team(name) do
    changeset = OpponentTeam.changeset(%OpponentTeam{}, %{name: name})
    {:ok, opponent_team} = Repo.insert(changeset)
    opponent_team
  end

  defp insert_valid_match(changeset) do
    case changeset.valid? do
      true  -> insert_match(changeset)
      false -> 0
    end
  end

  defp insert_match(changeset) do
    case Repo.insert(changeset) do
      {:ok, _} -> 1
      _        -> 0
    end
  end
end
