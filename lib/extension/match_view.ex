defmodule ClubHomepage.Extension.MatchView do
  alias Phoenix.HTML
  alias Phoenix.HTML.Tag

  import ClubHomepageWeb.Gettext
  import ClubHomepageWeb.Localization
  import ClubHomepage.Extension.CommonTimex, only: [point_of_time: 2]

  alias ClubHomepage.Match

  @no_match_result "- : -"

  def match_in_progress?(match) do
    Match.in_progress?(match)
  end

  def match_finished?(match) do
    Match.finished?(match)
  end

  def within_hours_before_kick_off?(match, hours) do
    Timex.compare(match.start_at, Timex.local) == 1 && Timex.compare(match.start_at, Timex.add(Timex.now, Timex.Duration.from_hours(hours))) == -1
  end

  def match_datetime(match, format \\ "#{datetime_format()} #{gettext("o_clock")}") do
    match.start_at
    |> point_of_time(format)
  end

  def match_result(match) do
    case !!(match.team_goals && match.opponent_team_goals) do
      true -> match_goals_string(match)
      _ -> match_failure(match)
    end
  end

  @doc """
  Returns a string, which shows the match result has been made after
  an extra time or after penalties. 

  ## Example usage
  iex> ClubHomepage.Extension.MatchView.match_result_extension(%ClubHomepage.Match{after_extra_time: false, after_penalty_shootout: false})
  {:safe, "<div></div>"}
  iex> ClubHomepage.Extension.MatchView.match_result_extension(%ClubHomepage.Match{after_extra_time: true, after_penalty_shootout: false})
  {:safe, "<div>AET</div>"}
  iex> ClubHomepage.Extension.MatchView.match_result_extension(%ClubHomepage.Match{after_extra_time: true, after_penalty_shootout: true})
  {:safe, "<div>APS</div>"}
  """
  @spec match_result_extension(ClubHomepage.Match) :: String
  def match_result_extension(match) do
    Tag.content_tag(:div) do
      cond do
        match.after_penalty_shootout -> gettext("after_penalty_shootout_abbreviation")
        match.after_extra_time -> gettext("after_extra_time_abbreviation")
        true -> ""
      end
    end
    |> HTML.safe_to_string()
    |> HTML.raw()
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
    Gettext.dgettext(ClubHomepageWeb.Gettext, "additionals", "failure_reason_" <> match.failure_reason)
  end
end
