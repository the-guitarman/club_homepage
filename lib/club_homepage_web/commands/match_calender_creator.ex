defmodule ClubHomepageWeb.MatchCalendarCreator do
  @moduledoc """
  Generates an ical file content with matches in the future. 
  """

  alias ClubHomepage.Address
  alias ClubHomepage.Match
  alias ClubHomepage.Repo

  import Ecto.Query, only: [from: 2]
  import ClubHomepageWeb.Gettext
  import ClubHomepageWeb.Localization
  import ClubHomepage.Extension.CommonTimex

  @doc """
  Returns an ical file content with matches in the future from now for a given team_id and a season_id.
  """
  @spec run(Integer.t, Integer.t) :: String.t
  def run(team_id, season_id \\ nil) do
    events = 
      get_matches(team_id, season_id)
      |> create_events
    %ICalendar{events: events} |> ICalendar.to_ics
  end

  @doc """
  Returns true if there are matches in the future from now for a given team_id and a season_id. Otherwise false.
  """
  @spec available?(Integer.t, Integer.t) :: Boolean.t
  def available?(team_id, season_id \\ nil) do
    not Enum.empty?(get_matches(team_id, season_id))
  end

  defp get_matches(team_id, season_id) do
    start_at = to_timex_ecto_datetime(Timex.local)
    Repo.all(from(m in Match, preload: [:competition, :team, :opponent_team, :meeting_point], where: m.team_id == ^team_id, where: m.season_id == ^season_id, where: m.start_at > ^start_at))
  end

  defp create_events(matches) do
    Enum.map(matches, fn(match) -> create_event(match) end)
  end

  defp create_event(match) do
    struct = %ICalendar.Event{
      summary: summary(match),
      dtstart: timex_datetime_to_utc(match.start_at), #meeting_point_at
      dtend: timex_datetime_to_utc(Timex.shift(match.start_at, hours: 3)),
      description: match.competition.name,
      location: location(match),
      geo: geo(match)#,
      #trigger: trigger(match)
    }
    Map.put(struct, :uid, match.uid)
  end

  defp summary(match) do
    if match.home_match do
      match.team.name <> " - " <> match.opponent_team.name
    else
      match.opponent_team.name <> " - " <> match.team.name
    end
  end

  defp timex_datetime_to_utc(datetime) do
    timezone = Timex.Timezone.get("UTC", Timex.now)
    Timex.Timezone.convert(datetime, timezone)
  end

  defp location(match) do
    ret = 
      case match.home_match do
        true ->
          match.meeting_point
          |> meeting_point_address()
          |> meeting_point_label()
        _ ->
          temp_1 =
            match.meeting_point
            |> meeting_point_address()
            |> meeting_point_label()
          temp_2 =
            match.opponent_team.address_id
            |> address()
            |> match_location_label()
          temp_1 <> "\n\n" <> temp_2
      end
    time_of_meeting(match.meeting_point_at) <> ret
  end

  defp meeting_point_address(nil), do: ""
  defp meeting_point_address(meeting_point) do
    meeting_point.address_id
    |> address()
  end

  defp meeting_point_label(""), do: ""
  defp meeting_point_label(address) do
    gettext("meeting_point") <> ":\n" <> address
  end

  defp match_location_label(""), do: ""
  defp match_location_label(address) do
    gettext("match_location") <> ":\n" <> address
  end

  defp time_of_meeting(nil), do: ""
  defp time_of_meeting(meeting_point_at) do
    ret = 
      meeting_point_at
    |> Timex.local
    |> Timex.format(datetime_format(), :strftime)
    case ret do
      {:ok, datetime} -> gettext("time_of_meeting") <> ":\n" <> datetime <> " " <> gettext("o_clock") <> "\n\n"
      _ -> ""
    end
  end

  def address(nil), do: ""
  def address(address_id) do
    case get_address(address_id) do
      nil -> ""
      address -> "#{address.street}, \n#{address.zip_code} #{address.city}#{district(address)}#{coordinates(address)}"
    end
  end

  defp get_address(nil), do: nil
  defp get_address(address_id) when is_integer(address_id) do
    case Repo.get(Address, address_id) do
      nil -> ""
      address -> address
    end
  end
  defp get_address(model), do: get_address(model.address_id)

  defp district(address) do
    case address.district do
      nil -> ""
      district -> " (#{district})"
    end
  end

  defp coordinates(address) do
    case address.latitude do
      nil -> ""
      latitude -> ", \nlat: #{latitude}, lng: #{address.longitude}"
    end
  end

  defp geo(match) do
    case match.home_match do
      true ->
        match.meeting_point
        |> get_address()
        |> geo_coordinates()
        |> geo_coordinates_fallback()
      _ ->
        match.opponent_team
        |> get_address()
        |> geo_coordinates()
    end
    |> nil_to_empty_string()
  end

  defp geo_coordinates(nil), do: ""
  defp geo_coordinates(address) do
    case address.latitude do
      nil -> ""
      latitude -> "#{latitude};#{address.longitude}"
    end
  end

  defp geo_coordinates_fallback(nil) do
    coordinates = Application.get_env(:club_homepage, :common)[:coordinates]
    "#{coordinates[:lat]};#{coordinates[:lon]}"
  end
  defp geo_coordinates_fallback(ret), do: ret

  defp nil_to_empty_string(nil), do: ""
  defp nil_to_empty_string(ret), do: ret

  #defp trigger(match) do
  #  case match.home_match do
  #    true -> "-P1H"
  #    _ -> "-P2H"
  #  end
  #end
end
