defmodule ClubHomepage.WeatherDataTest do
  use ClubHomepage.ModelCase
  use ExUnit.Case
  doctest ClubHomepage.WeatherData


  test "test_sd" do
    case ClubHomepage.WeatherData.get do
      {:ok, weather_data} ->
        %{year: current_year, month: current_month, day: current_day} = Timex.DateTime.local
        %{year: year, month: month, day: day} = weather_data[:created_at]
        assert year === current_year
        assert month === current_month
        assert day === current_day
        assert weather_data[:temperature] === "14°C"
        assert weather_data[:weather] === "cloudy"
        assert weather_data[:wind_speed] === "11 km/h"
      {:error, empty_map} ->
        assert Enum.empty?(empty_map)
    end
  end
end
