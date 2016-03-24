defmodule ClubHomepage.Extension.MatchView do
  import ClubHomepage.Gettext

  def match_datetime(match, format \\ "%d.%m.%Y %H:%M #{gettext("o_clock")}") do
    {:ok, date_string} = Timex.DateFormat.format(match.start_at, format, :strftime)
    date_string
  end

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
