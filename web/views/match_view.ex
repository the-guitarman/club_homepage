defmodule ClubHomepage.MatchView do
  use ClubHomepage.Web, :view

  import ClubHomepage.Extension.MatchView

  alias ClubHomepage.Match

  def meeting_point_showable?(conn, match) do
    !!match.meeting_point && not Match.finished?(match) && logged_in?(conn)
  end

  def meeting_point_has_coords?(nil), do: false
  def meeting_point_has_coords?(meeting_point) do
    address_has_coords?(meeting_point.address)
  end

  def opponent_team_map_options(match) do
    case match.opponent_team.address do
      nil -> ""
      address ->
        %{headline: gettext("match_address"), name: match.opponent_team.name, address: map_marker_address(address), lat: address.latitude, lng: address.longitude}
        |> to_json
    end
  end

  def meeting_point_map_options(match) do
    address = match.meeting_point.address
    %{headline: gettext("meeting_point"), name: match.meeting_point.name, address: map_marker_address(address), lat: address.latitude, lng: address.longitude}
    |> to_json
  end

  def to_json(object) do
    case JSON.encode(object) do
      {:ok, json} -> json
      _           -> ""
    end
  end

  defp map_marker_address(address) do
    html = address.street <> "<br />" <> address.zip_code <> " " <> address.city
    case address_has_coords?(address) do
      false -> html
      true  -> html <> "<br />" <> "lat:#{address.latitude}, lng:#{address.longitude}"
    end
  end

  def address_has_coords?(address) do
    !!(address.latitude && address.longitude)
  end

  def failure_reason_options do
    Enum.map(failure_reasons, fn(key) -> {Gettext.gettext(ClubHomepage.Gettext, "failure_reason_" <> key), key} end)
  end
end
