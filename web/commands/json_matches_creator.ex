defmodule ClubHomepage.JsonMatchesCreator do
  @moduledoc """
  Creates matches from a json.
  """

  alias ClubHomepage.JsonMatchesValidator
  alias ClubHomepage.Competition
  alias ClubHomepage.Match
  alias ClubHomepage.OpponentTeam
  alias ClubHomepage.Repo

  @doc """
  Creates matches from a valid changeset returned by JsonMatchesValidator. 
  """
  #@spec run(Ecto.Changeset) :: Integer
  def run(changeset, json_field) do
    params     = changeset.params
    season_id  = params["season_id"]
    team_id    = params["team_id"]
    {:ok, map} = JSON.decode(params[json_field])
    team_name = map["team_name"]
    create_matches(season_id, team_id, map["matches"], team_name)
  end

  defp create_matches(season_id, team_id, matches_maps, team_name) do
    records_count = 0
    for match_map <- matches_maps do
      records_count = records_count + create_match(season_id, team_id, match_map, team_name)
    end
    records_count
  end 

  defp create_match(season_id, team_id, match_map, team_name) do
    map =
      match_map
      |> Map.put("competition_id", competition_id(match_map["competition"]))
      |> Map.put("season_id", season_id)
      |> Map.put("team_id", team_id)
      |> Map.put("opponent_team_id", opponent_team_id(opponent_team_name(team_name, match_map)))
      |> Map.put("start_at", parse_start_at(match_map["start_at"]))
      |> Map.put("home_match", home_match(team_name, match_map))
    changeset = Match.changeset(%Match{}, map)
    insert_valid_match(changeset)
  end

  defp parse_start_at(value) do
    case JsonMatchesValidator.to_timex_date_format(value) do
      {:ok, datetime} -> datetime
      {:error, _error}  -> nil
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
    changeset = Competition.changeset(%Competition{}, %{name: name})
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
