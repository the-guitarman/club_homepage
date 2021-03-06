require Ecto.Query

defmodule ClubHomepageWeb.MatchView do
  use ClubHomepageWeb, :view

  import ClubHomepage.Extension.MatchView

  alias ClubHomepage.Match

  def finished?(match) do
    Match.finished?(match)
  end

  def meeting_point_showable?(conn, match) do
    !!match.meeting_point && not Match.finished?(match) && logged_in?(conn)
  end

  def meeting_point_at_showable?(conn, match) do
    !!match.meeting_point_at && not Match.finished?(match) && logged_in?(conn)
  end

  @doc """
  Returns wether the given meeting point 

  # Examples
  iex> import ClubHomepage.Factory
  ...> ClubHomepageWeb.MatchView.meeting_point_has_coords?(nil)
  false
  ...> address = insert(:address, latitude: nil, longitude: nil)
  ...> meeting_point = insert(:meeting_point, address_id: address.id)
  ...> meeting_point = ClubHomepage.Repo.preload(meeting_point, :address)
  ...> ClubHomepageWeb.MatchView.meeting_point_has_coords?(meeting_point)
  false
  iex> address = insert(:address, latitude: 1, longitude: 1)
  ...> meeting_point = insert(:meeting_point, address_id: address.id)
  ...> meeting_point = ClubHomepage.Repo.preload(meeting_point, :address)
  ...> ClubHomepageWeb.MatchView.meeting_point_has_coords?(meeting_point)
  true
  """
  @spec meeting_point_has_coords?(ClubHomepage.MeetingPoint | nil) :: Boolean
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
    Enum.map(failure_reasons(), fn(key) -> {Gettext.dgettext(ClubHomepageWeb.Gettext, "additionals", "failure_reason_" <> key), key} end)
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
      Ecto.Query.from(u in ClubHomepage.User, select: [u.id], where: like(u.roles, "%player%"))
      |> ClubHomepage.Repo.all()
      |> Enum.map(fn([id]) -> internal_user_name(id) end)
      |> Enum.sort()

    guest_players = 1..21

    cond do
      position == "left" && match.home_match == true -> club_players
      position == "right" && match.home_match == false -> club_players
      true -> guest_players
    end
  end
end
