defmodule ClubHomepage.Extension.MatchView do
  def match_result(match) do
    if match.team_goals && match.opponent_team_goals do
      if match.home_match do
        goals_string(match.team_goals, match.opponent_team_goals)
      else
        goals_string(match.opponent_team_goals, match.team_goals)
      end
    else
      "- : -"
    end
  end

  defp goals_string(goals_team_1, goals_team_2) do
    Integer.to_string(goals_team_1) <> " : " <> Integer.to_string(goals_team_2)
  end
end
