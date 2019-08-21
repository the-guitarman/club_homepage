defmodule ClubHomepage.WeatherDataTest do
  use ClubHomepage.ModelCase
  use ExUnit.Case
  doctest ClubHomepageWeb.WeatherData
  alias ClubHomepageWeb.WeatherData


  test "test_sd" do
    case WeatherData.get do
      {:ok, weather_data} ->
        %{year: current_year, month: current_month, day: current_day} = Timex.local
        %{year: year, month: month, day: day} = weather_data[:created_at]
        assert year === current_year
        assert month === current_month
        assert day === current_day
        assert weather_data[:temperature] =~ ~r{\d+°C}
        assert weather_data[:weather] =~ ~r{\w+( \w+)*}
        assert weather_data[:wind_speed] =~ ~r{\d+ km/h}
      {:error, empty_map} ->
        assert Enum.empty?(empty_map)
    end
  end
end
