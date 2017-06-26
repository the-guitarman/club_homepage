defmodule ClubHomepage.Web.PageView do
  use ClubHomepage.Web, :view

  import ClubHomepage.Extension.MatchView

  def next_and_last_matches_cols(next_matches, last_matches) do
    cond do
      Enum.count(next_matches) > 0 && Enum.count(last_matches) > 0 -> 6
      true -> 12
    end
  end
end
