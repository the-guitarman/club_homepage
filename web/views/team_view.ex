defmodule ClubHomepage.TeamView do
  use ClubHomepage.Web, :view

  import ClubHomepage.Extension.MatchView

  def match_datetime(match, format \\ "%d.%m.%Y %H:%M #{gettext("o_clock")}") do
    {:ok, date_string} = Timex.DateFormat.format(match.start_at, format, :strftime)
    date_string
  end
end
