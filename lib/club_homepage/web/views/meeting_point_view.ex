defmodule ClubHomepage.Web.MeetingPointView do
  use ClubHomepage.Web, :view

  def full_address(meeting_point) do
    case address_loaded?(meeting_point) do
      false -> ""
      _ -> base_address(meeting_point) <> " " <>
           get_district(meeting_point)# <> " " <>
           #get_geo_coordinates(meeting_point)
    end
  end

  defp base_address(meeting_point) do
    address = meeting_point.address
    address.street <> ", " <> address.zip_code <> " " <> address.city
  end

  defp get_district(meeting_point) do
    address = meeting_point.address
    case address.district do
      nil -> ""
      ""  -> ""
      _   -> (address.district)
    end
  end

  defp address_loaded?(meeting_point) do
    Ecto.assoc_loaded?(meeting_point.address)
  end

  # defp get_geo_coordinates(meeting_point) do
  #   address = meeting_point.address
  #   case !!(address.latitude && address.longitude) do
  #     false -> ""
  #     true  -> "- " <>
  #       Float.to_string(Float.round(address.latitude, 7)) <> ", " <>
  #       Float.to_string(Float.round(address.longitude, 7))
  #   end
  # end
end
