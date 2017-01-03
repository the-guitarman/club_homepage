defmodule ClubHomepage.ClubHomepageTest do
  use ClubHomepage.ModelCase

  test "founding year is an integer" do
    %{year: current_year} = Timex.local
    start_year = Application.get_env(:club_homepage, :common)[:founding_year]
    assert is_integer(start_year)
    assert String.length(Integer.to_string(start_year)) === 4
    assert start_year <= current_year
  end

  test "full_club_name is setup" do
    name = Application.get_env(:club_homepage, :common)[:full_club_name]
    assert is_bitstring(name)
    assert String.length(name) > 0
  end
end
