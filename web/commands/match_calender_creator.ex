# Die UID weist das Format "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX" auf, wobei X einem hexadezimalen Zeichen (0-9, A-F) entspricht.
defmodule ClubHomepage.MatchCalendarCreator do
  @moduledoc """
  Generates an ical file content with matches in the future. 
  """

  alias ClubHomepage.Address
  alias ClubHomepage.Match
  alias ClubHomepage.Repo

  import Ecto.Query, only: [from: 2]
  import ClubHomepage.Gettext
  import ClubHomepage.Extension.CommonTimex

  @doc """
  Returns an ical file content with matches in the future from now for a given team_id and a season_id.
  """
  #@spec run(Integer, Integer) :: ICalendar
  def run(team_id, season_id \\ nil) do
    events = 
      get_matches(team_id, season_id)
      |> create_events
    %ICalendar{events: events} |> ICalendar.to_ics
  end

  @doc """
  Returns true if there are matches in the future from now for a given team_id and a season_id. Otherwise false.
  """
  @spec available?(Integer, Integer) :: Boolean
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
      location: location(match)
    }
    Map.put(struct, :uid, uid(match))
  end

  defp uid(match) do
    :crypto.hash(:sha, "#{match.id}#{summary(match)}#{match.competition.name}")
    |> Base.encode16(case: :lower)
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
    ret = meeting_point(match.meeting_point)
    ret = 
      case match.home_match do
        true -> meeting_point_label(ret)
        _ -> meeting_point_label(ret) <> "\n\n" <> match_location_label(address(match.opponent_team.address_id))
      end
    time_of_meeting(match.meeting_point_at) <> ret
  end

  defp time_of_meeting(nil), do: ""
  defp time_of_meeting(meeting_point_at) do
    ret = 
      meeting_point_at
      |> Timex.local
      |> Timex.format("%d.%m.%Y %H:%M", :strftime)
    case ret do
      {:ok, datetime} -> gettext("time_of_meeting") <> ":\n" <> datetime <> " " <> gettext("o_clock") <> "\n"
      _ -> ""
    end
  end

  defp meeting_point(nil), do: ""
  defp meeting_point(meeting_point) do
    address(meeting_point.address_id)
  end

  defp meeting_point_label(""), do: ""
  defp meeting_point_label(address) do
    gettext("meeting_point") <> ":\n" <> address
  end

  defp match_location_label(""), do: ""
  defp match_location_label(address) do
    gettext("match_location") <> ":\n" <> address
  end

  def address(nil), do: ""
  def address(address_id) do
    case Repo.get(Address, address_id) do
      nil -> ""
      address -> "#{address.street}, \n#{address.zip_code} #{address.city}#{district(address)}#{coordinates(address)}"
    end
  end

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
end
