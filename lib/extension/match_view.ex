defmodule ClubHomepage.Extension.MatchView do
  import ClubHomepage.Gettext

  @no_match_result "- : -"

  def match_datetime(match, format \\ "%d.%m.%Y %H:%M #{gettext("o_clock")}") do
    {:ok, date_string} = Timex.DateFormat.format(match.start_at, format, :strftime)
    date_string
  end

  def match_result(match) do
    case !!(match.team_goals && match.opponent_team_goals) do
      true -> match_goals_string(match)
      _ -> match_failure(match)
    end
  end

  def match_failure_class(match) do
    case match_failure?(match) do
      true -> "text-danger"
      _ -> ""
    end
  end

  defp match_failure?(match) do
    not is_nil(match.failure_reason)
  end

  defp match_failure(match) do
    case match_failure?(match) do
      true -> Gettext.gettext(ClubHomepage.Gettext, "failure_reason_" <> match.failure_reason)
      _ -> @no_match_result
    end
  end

  defp match_goals_string(match) do
    case match.home_match do
      true -> goals_string(match.team_goals, match.opponent_team_goals)
      _    -> goals_string(match.opponent_team_goals, match.team_goals)
    end
  end

  defp goals_string(goals_team_1, goals_team_2) do
    Integer.to_string(goals_team_1) <> " : " <> Integer.to_string(goals_team_2)
  end
end
