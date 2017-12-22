defmodule ClubHomepage.Web.TeamView do
  use ClubHomepage.Web, :view

  import ClubHomepage.Extension.MatchView

  alias ClubHomepage.Match
  alias ClubHomepage.MatchCommitment
  alias ClubHomepage.Repo
  alias ClubHomepage.User

  @spec finished?( Match ) :: Boolean
  def finished?(match) do
    Match.finished?(match)
  end

  @spec has_no_goals( Match ) :: Boolean
  def has_no_goals(match) do
    match.team_goals == nil && match.opponent_team_goals == nil
  end

  @spec find_match_commitment( Match, User) :: Boolean
  def find_match_commitment(match, user) do
    case Repo.get_by(MatchCommitment, match_id: match.id, user_id: user.id) do
      nil -> %{commitment: nil}
      match_commitment -> match_commitment
    end
  end
end
