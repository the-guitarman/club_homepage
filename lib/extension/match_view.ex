defmodule ClubHomepage.Extension.MatchView do
  alias Phoenix.HTML
  alias Phoenix.HTML.Tag

  import ClubHomepage.Gettext

  alias ClubHomepage.Match

  @no_match_result "- : -"

  def match_in_progress?(match) do
    Match.in_progress?(match)
  end

  def match_finished?(match) do
    Match.finished?(match)
  end

  def within_hours_before_kick_off?(match, hours) do
    Timex.compare(match.start_at, Timex.local) == 1 && Timex.compare(match.start_at, Timex.add(Timex.local, Timex.Duration.from_hours(hours))) == -1
  end

  def match_datetime(match, format \\ "%d.%m.%Y %H:%M #{gettext("o_clock")}") do
    match.start_at
    |> Timex.local
    |> point_of_time(format)
  end

  def point_of_time(time, format \\ "%d.%m.%Y %H:%M #{gettext("o_clock")}") do
    {:ok, date_string} = Timex.format(time, format, :strftime)
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

  defp match_aborted?(match) do
    match.failure_reason == "aborted"
  end

  defp match_failure(match) do
    case match_failure?(match) do
      true -> match_failure_translation(match)
      _ -> @no_match_result
    end
  end

  defp match_goals_string(match) do
    case match.home_match do
      true -> goals_string(match, match.team_goals, match.opponent_team_goals)
      _    -> goals_string(match, match.opponent_team_goals, match.team_goals)
    end
  end

  defp goals_string(match, goals_team_1, goals_team_2) do
    goals_div = Tag.content_tag(:div) do
      Integer.to_string(goals_team_1) <> " : " <> Integer.to_string(goals_team_2)
    end

    case match_aborted?(match) do
      true ->
        failure_reason_div = Tag.content_tag(:div, class: "failure-reason") do
          match_failure_translation(match)
        end
        HTML.raw(HTML.safe_to_string(goals_div) <> HTML.safe_to_string(failure_reason_div))
      _ -> goals_div
    end
  end

  defp match_failure_translation(match) do
    Gettext.dgettext(ClubHomepage.Gettext, "additionals", "failure_reason_" <> match.failure_reason)
  end
end
