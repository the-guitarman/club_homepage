defmodule ClubHomepage.Extension.Controller do
  @moduledoc """
  This module provides functions for recurring tasks within a controller.
  """

  alias ClubHomepageWeb.Localization
  alias ClubHomepage.Extension.CommonTimex

  @doc """
  Returns the full club name as configured in `config/club_homepage.exs`.
  """
  @spec full_club_name() :: String
  def full_club_name do
    Application.get_env(:club_homepage, :common)[:full_club_name]
  end

  @doc """
  Returns the short club name as configured in `config/club_homepage.exs`.
  """
  @spec short_club_name() :: String
  def short_club_name do
    Application.get_env(:club_homepage, :common)[:short_club_name]
  end

  @doc """
  Parses a date string in the given parameters and replaces it with a timex object.

  ## Example usage
  iex> ClubHomepage.Extension.Controller.parse_date_field(%{"date" => "2017-04-02"}, :date)
  %{"date" => Timex.to_datetime({{2017, 4, 2}, {0, 0, 0}}, Timex.Timezone.get(Timex.Timezone.Local.lookup, Timex.local))}

  iex> ClubHomepage.Extension.Controller.parse_date_field(%{"date" => "2017-04-02 12:30"}, :date)
  %{"date" => nil}
  """
  # https://github.com/bitwalker/timex#formatting-a-datetime-via-strftime
  @spec parse_date_field(Map, Atom, String | Nil) :: Map
  def parse_date_field(params, field, format \\ nil) do
    format = Localization.date_format(format)
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
        Map.put(params, field_name, CommonTimex.utc_to_local_datetime(timex_naive_datetime))
      {:error, _error} ->
        Map.put(params, field_name, nil)
    end
  end

  @doc """
  Parses a datetime string in the given parameters and replaces it with a timex object.

  ## Example usage
  iex> ClubHomepage.Extension.Controller.parse_datetime_field(%{"datetime" => "2017-04-02 12:30"}, :datetime)
  %{"datetime" => Timex.to_datetime({{2017, 4, 2}, {12, 30, 0}}, Timex.Timezone.get(Timex.Timezone.Local.lookup, Timex.local))}

  iex> ClubHomepage.Extension.Controller.parse_datetime_field(%{"datetime" => "2017-04-02"}, :datetime)
  %{"datetime" => nil}
  """
  @spec parse_datetime_field(Map, Atom, String | Nil) :: Map
  def parse_datetime_field(params, field, format \\ nil) do
    format = Localization.datetime_format(format)
    parse_date_field(params, field, format)
  end
end
