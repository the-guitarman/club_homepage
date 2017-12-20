defmodule ClubHomepage.Web.TeamView do
  use ClubHomepage.Web, :view

  import ClubHomepage.Extension.MatchView

  alias ClubHomepage.Match

  @spec finished?( Match ) :: Boolean
  def finished?(match) do
    Match.finished?(match)
  end

  def has_no_goals(match) do
    match.team_goals == nil && match.opponent_team_goals == nil
  end
end
