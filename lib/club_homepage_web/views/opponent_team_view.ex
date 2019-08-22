defmodule ClubHomepageWeb.OpponentTeamView do
  use ClubHomepageWeb, :view

  def full_address(opponent_team) do
    case opponent_team.address do
      nil -> ""
      address -> base_address(address) <> " " <> get_district(address)
    end
  end

  defp base_address(address) do
    address.street <> ", " <> address.zip_code <> " " <> address.city
  end

  defp get_district(address) do
    case address.district do
      nil -> ""
      ""  -> ""
      _   -> (address.district)
    end
  end
end
