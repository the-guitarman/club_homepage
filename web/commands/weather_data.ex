defmodule ClubHomepage.WeatherData do
  use GenServer

  def start_link(initial_value) do
    IO.inspect __MODULE__
    ret = GenServer.start_link(__MODULE__, initial_value, name: __MODULE__)
    IO.inspect ret
    ret
  end

  def init(_initial_value) do
    {:ok, get_data}
  end

  def handle_call(:get, _from, value) do
    new_value = 
      case cached_data_should_be_updated?(value) do
        true ->
          IO.inspect "1"
          get_data
        _    ->
          IO.inspect "2"
          value
      end
    {:reply, new_value, new_value}
  end




  def get do
    GenServer.call __MODULE__, :get
  end




  @api_key "cb3b951fc2b009115c9f5ac870360ba6"
  @lang "de"
  @city "Claussnitz"

  defp get_data do
    "http://api.openweathermap.org/data/2.5/weather?q=#{@city}&lang=#{@lang}&appid=#{@api_key}"
    #|> request_api
    |> request_dummy
    |> parse
    |> create_data_map
  end

  defp request_dummy(_url) do
    {:ok, data} = Poison.encode(%{"base" => "stations", "clouds" => %{"all" => 76}, "cod" => 200,
      "coord" => %{"lat" => 50.93, "lon" => 12.88}, "dt" => 1474494204,
      "id" => 2939997,
      "main" => %{"grnd_level" => 997.48, "humidity" => 97, "pressure" => 997.48,
                  "sea_level" => 1026.54, "temp" => 287.625, "temp_max" => 287.625,
                  "temp_min" => 287.625}, "name" => "Claussnitz",
      "sys" => %{"country" => "DE", "message" => 0.0153, "sunrise" => 1474433699,
                 "sunset" => 1474477575},
      "weather" => [%{"description" => "überwiegend bewölkt", "icon" => "04n",
                      "id" => 803, "main" => "Clouds"}],
      "wind" => %{"deg" => 246, "speed" => 2.91}})
    data
  end

  defp cached_data_should_be_updated?(data) do
    data[:created_at] < (timestamp_now - 84600)
  end

  defp request_api(url) do
    case HTTPoison.get(url) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} -> body
      {:ok, %HTTPoison.Response{status_code: 404}} -> nil
      {:error, %HTTPoison.Error{reason: reason}} ->
        IO.inspect reason
        nil
    end
  end

  defp parse(nil), do: nil
  defp parse(body) do
    case Poison.decode(body) do
      {:ok, data} -> data
      {:error, reason} ->
        IO.inspect reason
        nil
    end
  end

  defp create_data_map(nil), do: nil
  defp create_data_map(data) do
    centigrade =
      data["main"]["temp"]
      |> kelvin_to_centigrade()
      |> round_value(1)

    fahrenheit = centigrade_to_fahrenheit(centigrade)

    [%{"description" => description} | tail] = data["weather"]

    wind_in_meters_per_second =
      data["wind"]["speed"]
      |> round_value(1)

    wind_in_kilometers_per_hour =
      meters_per_second_to_kilometers_per_hour(wind_in_meters_per_second)
      |> round_value

    %{created_at: timestamp_now, centigrade: centigrade, fahrenheit: fahrenheit, weather: description, wind_in_kilometers_per_hour: wind_in_kilometers_per_hour, wind_in_meters_per_second: wind_in_meters_per_second}
  end

  defp round_value(value, precision \\ 0) when is_float(value) do
    Float.round(value)
  end
  defp round_value(value, _precision), do: value

  defp kelvin_to_centigrade(value) do
    value - 273.15
  end

  defp centigrade_to_fahrenheit(value) do
    ((value * 9) / 5) + 32
  end

  defp meters_per_second_to_kilometers_per_hour(value) do
    value * 3.6 #0.868976242 #1.609
  end

  defp timestamp_now do
    Timex.DateTime.local
    |> Timex.to_unix()
  end
end
