defmodule ClubHomepage.MatchCalendarTest do
  use ClubHomepage.ModelCase
  use ExUnit.Case
  doctest ClubHomepage.JsonMatchesCreator

  alias ClubHomepage.JsonMatchesValidator
  alias ClubHomepage.JsonMatchesCreator
  alias ClubHomepage.Competition
  alias ClubHomepage.Match
  alias ClubHomepage.OpponentTeam

  import ClubHomepage.Factory
  import Ecto.Query, only: [from: 2]

  test "run" do

  end

  test "available?" do

  end
end
