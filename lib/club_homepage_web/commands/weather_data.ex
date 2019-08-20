defmodule ClubHomepage.Web.WeatherData do
  @moduledoc """
  Receives weather data from an external api.
  """

  import Plug.Conn

  use Number

  @doc false
  def init(_opts) do
    nil
  end

  @doc false
  def call(conn, _) do
    {_, data} = get()
    assign(conn, :weather_data, data)
  end

  @doc """
  Receives weather data from an external api.
  """
  @spec get() :: {Atom, Map}
  def get do
    # {:ok, %{centigrade: 7.8, created_at: 1476902712, fahrenheit: 46.04, weather: "leichter Regen", wind_in_kilometers_per_hour: 18.0, wind_in_meters_per_second: 5.1}}
    ElixirWeatherData.get()
    |> format_temperature()
    |> format_wind()
    |> format_created_at()
  end

  defp format_temperature({:error, _}), do: {:error, %{}}
  defp format_temperature({:ok, data}) do
    key =
      case Application.get_env(:club_homepage, :weather_data_units)[:temperature] do
        :centigrade -> :centigrade
        :fahrenheit -> :fahrenheit
        _ -> :centigrade
      end
    {number, _key} = Map.pop(data, key)

    result =
      data
      |> Map.drop([:centigrade, :fahrenheit])
      |> Map.put_new(:temperature, Number.Delimit.number_to_delimited(number, precision: precision(number)) <> "°C")
    {:ok, result}
  end

  defp format_wind({:error, _}), do: {:error, %{}}
  defp format_wind({:ok, data}) do
    key =
      case Application.get_env(:club_homepage, :weather_data_units)[:wind_speed] do
        :meters_per_second -> :wind_in_meters_per_second
        :kilometers_per_hour -> :wind_in_kilometers_per_hour
        _ -> :wind_in_kilometers_per_hour
      end
    {number, _key} = Map.pop(data, key)

    result =
      data
      |> Map.drop([:wind_in_kilometers_per_hour, :wind_in_meters_per_second])
      |> Map.put_new(:wind_speed, Number.Delimit.number_to_delimited(number, precision: precision(number)) <> " km/h")
    {:ok, result}
  end

  defp format_created_at({:error, _}), do: {:error, %{}}
  defp format_created_at({:ok, data}) do
    {:ok, Map.put(data, :created_at, ClubHomepage.DateTime.Convert.to_timex_datetime(data[:created_at]))}
  end

  defp precision(number) do
    case number == round(number) do
      true -> 0
      _ -> 1
    end
  end
end
