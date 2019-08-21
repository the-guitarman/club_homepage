defmodule ClubHomepageWeb.PageView do
  use ClubHomepageWeb, :view

  import ClubHomepage.Extension.MatchView

  def with_or_without_logo_image_cols(logo_path) do
    case asset_path?(logo_path) do
      true -> 4
      _ -> 6
    end
  end

  def next_and_last_matches_cols(next_matches, last_matches) do
    cond do
      Enum.count(next_matches) > 0 && Enum.count(last_matches) > 0 -> 6
      true -> 12
    end
  end
end
