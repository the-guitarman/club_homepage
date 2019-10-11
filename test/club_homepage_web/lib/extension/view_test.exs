defmodule ClubHomepage.Extension.ViewTest do
  use ExUnit.Case
  doctest ClubHomepage.Extension.View

  alias ClubHomepage.Extension.View

  test "test full club name" do
    case System.get_env("TRAVIS") do
      nil -> assert String.length(View.full_club_name()) > 0
      _ -> assert View.full_club_name() == "Full Club Name"
    end
  end

  test "test short club name" do
    case System.get_env("TRAVIS") do
      nil -> assert String.length(View.short_club_name()) > 0
      _ -> assert View.full_club_name() == "Short Club Name"
    end
  end
end
