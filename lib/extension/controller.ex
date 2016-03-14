defmodule ClubHomepage.Extension.Controller do
  # https://github.com/bitwalker/timex#formatting-a-datetime-via-strftime
  def parse_date_field(params, field, format \\ "%d.%m.%Y") do
    field_name = Atom.to_string(field)

    params  
    |> extract_value(field_name)
    |> check_value
    |> parse_value(field_name, format)
  end

  defp extract_value(params, field_name), do: {:ok, params, params[field_name]}

  defp check_value({:ok, params, nil}), do: {:empty, params, nil}
  defp check_value({:ok, params, value}), do: {:ok, params, value}

  defp parse_value({:empty, params, nil}, _field_name, _format), do: params
  defp parse_value({:ok, params, value}, field_name, format) do
    case Timex.DateFormat.parse(value, format, :strftime) do
      {:ok, timex_datetime} -> Map.put(params, field_name, timex_datetime)
      {:error, error} ->
        IO.inspect error
        Map.put(params, field_name, nil)
    end
  end

  def parse_datetime_field(params, field, format \\ "%d.%m.%Y %H:%M") do
    parse_date_field(params, field, format)
  end

  def to_timex_ecto_datetime(timex_datetime) do
    {:ok, timex_ecto_datetime} = Timex.Ecto.DateTime.cast(timex_datetime)
    timex_ecto_datetime
  end
end
