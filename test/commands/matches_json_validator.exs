defmodule ClubHomepage.PermalinkGeneratorTest do
  use ClubHomepage.ModelCase
  use ExUnit.Case, async: true
  doctest ClubHomepage.MatchesJsonValidator

  alias ClubHomepage.MatchesJsonValidator
  alias ClubHomepage.Match

  import Ecto.Query, only: [from: 1, from: 2]

  # params = %{"_csrf_token" => "Al4YHRUKJlMLCwQgXHkeZAFgHmsHAAAAPfIrYXHeDLvZ2LJTq4nDlA==", "_utf8" => "✓", "match" => %{"json" => "{\r\n  \"team_name\": \"Name meiner Vereinsmannschaft\",\r\n  \"matches\": [\r\n    {\r\n      \"start_at\": \"Sonntag, 13.03.2016 - 12:00 Uhr\",\r\n      \"home\": \"Name der gegnerischen Mannschaft 1\",\r\n      \"guest\": \"Name meiner Vereinsmannschaft\"\r\n    },\r\n    {\r\n      \"start_at\": \"Sonntag, 03.04.2016 - 14:00 Uhr\",\r\n      \"home\": \"Name meiner Vereinsmannschaft\",\r\n      \"guest\": \"Name def gegnerischen Mannschaft 2\"\r\n    }\r\n  ]\r\n}", "season_id" => "", "team_id" => ""}}
  test "" do
  end
end
