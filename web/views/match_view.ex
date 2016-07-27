require Ecto.Query

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
    Enum.map(failure_reasons, fn(key) -> {Gettext.dgettext(ClubHomepage.Gettext, "additionals", "failure_reason_" <> key), key} end)
  end

  def match_in_progress?(match) do
    Match.in_progress?(match)
  end

  def match_finished?(match) do
    Match.finished?(match)
  end

  def within_hours_before_kick_off?(match, hours) do
    Timex.DateTime.compare(match.start_at, Timex.DateTime.local) == 1 && Timex.DateTime.compare(match.start_at, Timex.add(Timex.DateTime.local, Timex.Time.to_timestamp(hours, :hours))) == -1
  end

  def match_character(match) do
    competition = ClubHomepage.Repo.get!(ClubHomepage.Competition, match.competition_id)
    case competition.matches_need_decition do
      true -> "deciding-game"
      _ -> ""
    end
  end

  def channelize(conn, match) do
    case logged_in?(conn) && (match_in_progress?(match) || within_hours_before_kick_off?(match, 1)) do
      true -> "data-channelize=''"
      _ -> ""
    end
  end

  def match_players(match, position) do
    club_players = 
      Ecto.Query.from(u in ClubHomepage.User, select: [u.id, u.name], where: like(u.roles, "%player%"))
      |> ClubHomepage.Repo.all()
      |> Enum.map(fn([user_id, user_name]) -> user_name end)
      |> Enum.sort()

    guest_players = 1..21

    cond do
      position == "left" && match.home_match == true -> club_players
      position == "right" && match.home_match == false -> club_players
      true -> guest_players
    end
  end
end
