defmodule ClubHomepage.DateTime.Convert do
  epoch = {{1970, 1, 1}, {0, 0, 0}}
  @epoch :calendar.datetime_to_gregorian_seconds(epoch)


  @doc """
  Returns a datetime tuple for a given unix timestamp.

  ## Example usage
  iex> ClubHomepage.DateTime.Convert.to_datetime(1480194004)
  {{2016, 11, 26}, {21, 0, 4}}
  """
  def to_datetime(timestamp) do
    timestamp
    |> Kernel.+(@epoch)
    |> :calendar.gregorian_seconds_to_datetime
  end

  def to_timex_datetime(timestamp) do
    timestamp
    |> to_datetime
    |> Timex.to_datetime(:utc)
    |> Timex.local
  end

  @doc """
  Returns a unix timestamp for a given datetime tuple or a Timex.DateTime.

  ## Example usage
  iex> ClubHomepage.DateTime.Convert.to_timestamp({{2016, 11, 26}, {21, 0, 4}})
  1480194004
  """
  def to_timestamp({{year, month, day}, {hour, minute, second}}) do
    {{year, month, day}, {hour, minute, second}}
    |> convert_to_timestamp
  end
  def to_timestamp(%{year: year, month: month, day: day, hour: hour, minute: minute, second: second}) do
    {{year, month, day}, {hour, minute, second}}
    |> convert_to_timestamp
  end

  defp convert_to_timestamp(datetime) do
    datetime
    |> :calendar.datetime_to_gregorian_seconds
    |> Kernel.-(@epoch)
  end
end
