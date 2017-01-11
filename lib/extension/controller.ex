defmodule ClubHomepage.Extension.Controller do
  @moduledoc """
  This module provides functions for recurring tasks within a controller.
  """

  @doc """
  Parses a date string in the given parameters and replaces it with a timex object.

  ## Example usage
  iex> ClubHomepage.Extension.Controller.parse_date_field(%{"date" => "02.04.2017"}, :date)
  %{"date" => Timex.to_datetime({{2017, 4, 2}, {0, 0, 0}}, :local)}

  iex> ClubHomepage.Extension.Controller.parse_date_field(%{"date" => "02.04.2017 12:30"}, :date)
  %{"date" => nil}
  """
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
    case Timex.parse(value, format, :strftime) do
      {:ok, timex_naive_datetime} ->
        timezone = Timex.Timezone.get(Timex.Timezone.Local.lookup, Timex.local)
        timex_datetime = Timex.to_datetime(timex_naive_datetime, timezone)
        Map.put(params, field_name, timex_datetime)
      {:error, error} ->
        Map.put(params, field_name, nil)
    end
  end

  @doc """
  Parses a datetime string in the given parameters and replaces it with a timex object.

  ## Example usage
  iex> ClubHomepage.Extension.Controller.parse_datetime_field(%{"datetime" => "02.04.2017 12:30"}, :datetime)
  %{"datetime" => Timex.to_datetime({{2017, 4, 2}, {12, 30, 0}}, :local)}

  iex> ClubHomepage.Extension.Controller.parse_datetime_field(%{"datetime" => "02.04.2017"}, :datetime)
  %{"datetime" => nil}
  """
  def parse_datetime_field(params, field, format \\ "%d.%m.%Y %H:%M") do
    parse_date_field(params, field, format)
  end
end
