# Die UID weist das Format "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX" auf, wobei X einem hexadezimalen Zeichen (0-9, A-F) entspricht.
defmodule ClubHomepage.MatchCalendarCreator do
  @moduledoc """
  Generates an ical file content with matches in the future. 
  """

  alias ClubHomepage.Match
  alias ClubHomepage.Repo

  import Ecto.Query, only: [from: 1, from: 2]
  import ClubHomepage.Extension.CommonTimex

  # events = [
  #   %ICalendar.Event{
  #     summary: "Film with Amy and Adam",
  #     dtstart: {{2015, 12, 24}, {8, 30, 00}},
  #     dtend:   {{2015, 12, 24}, {8, 45, 00}},
  #     description: "Let's go see Star Wars.",
  #     location: "123 Fun Street, Toronto ON, Canada"
  #             },
  #   %ICalendar.Event{
  #     summary: "Morning meeting",
  #     dtstart: Timex.now,
  #     dtend:   Timex.shift(Timex.now, hours: 3),
  #     description: "A big long meeting with lots of details.",
  #     location: "456 Boring Street, Toronto ON, Canada"
  #   },
  # ]
  # ics = %ICalendar{ events: events } |> ICalendar.to_ics

  @doc """
  Returns an ical file content for a given team_id and a season_id.
  """
  #@spec run(Integer, Integer) :: ICalendar
  def run(team_id, season_id \\ nil) do
    events = 
      get_matches(team_id, season_id)
      |> create_events
    %ICalendar{events: events} |> ICalendar.to_ics
  end

  @spec available?(Integer, Integer) :: Boolean
  def available?(team_id, season_id \\ nil) do
    not Enum.empty?(get_matches(team_id, season_id))
  end

  defp get_matches(team_id, season_id) do
    start_at = to_timex_ecto_datetime(Timex.local)
    Repo.all(from(m in Match, preload: [:competition, :team, :opponent_team], where: m.team_id == ^team_id, where: m.season_id == ^season_id, where: m.start_at > ^start_at))
  end

  defp create_events(matches) do
    Enum.map(matches, fn(match) -> create_event(match) end)
  end

  defp create_event(match) do
    IO.inspect match
    {:ok, start_at} = Timex.format(timex_datetime_to_utc(match.start_at), "{ISO:Extended:Z}")
    {:ok, end_at} = Timex.format(timex_datetime_to_utc(Timex.shift(match.start_at, hours: 3)), "{ISO:Extended:Z}")

    struct = %ICalendar.Event{
      summary: summary(match),
      dtstart: start_at,
      dtend: end_at,
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

  defp location(match) do
    ""
  end

  defp timex_datetime_to_utc(datetime) do
    timezone = Timex.Timezone.get("UTC", Timex.now)
    Timex.Timezone.convert(datetime, timezone)
  end
end
