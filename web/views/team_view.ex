defmodule ClubHomepage.TeamView do
  use ClubHomepage.Web, :view

  import ClubHomepage.Extension.MatchView

  def has_no_goals(match) do
    match.team_goals == nil && match.opponent_team_goals == nil
  end
end
