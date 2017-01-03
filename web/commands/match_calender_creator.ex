# Die UID weist das Format "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX" auf, wobei X einem hexadezimalen Zeichen (0-9, A-F) entspricht.
defmodule ClubHomepage.MatchCalenderCreator do

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

end
