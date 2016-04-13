defmodule ClubHomepage.MeetingPointView do
  use ClubHomepage.Web, :view

  def full_address(meeting_point) do
    base_address(meeting_point) <> " " <>
      get_district(meeting_point) <> " " <>
      get_geo_coordinates(meeting_point)
  end

  defp base_address(meeting_point) do
    meeting_point.address.street <> ", " <>
      meeting_point.address.zip_code <> " " <>
      meeting_point.address.city
  end

  defp get_district(meeting_point) do
    case meeting_point.address.district do
      nil -> ""
      ""  -> ""
      _   -> (meeting_point.address.district)
    end
  end

  defp get_geo_coordinates(meeting_point) do
    address = meeting_point.address
    case !!(address.latitude && address.longitude) do
      false -> ""
      true  -> "- " <>
        Float.to_string(address.latitude) <> ", " <>
        Float.to_string(address.longitude)
    end
  end
end
