defmodule ClubHomepage.Extension.CommonTimex do
  import ClubHomepageWeb.Gettext
  import ClubHomepageWeb.Localization

  @doc """
  Converts a datetime into a string with given format and local timezone.

  ## Example usage
  iex> datetime = ~U[2019-08-18 20:04:05.894867Z]
  iex> ClubHomepage.Extension.CommonTimex.point_of_time(datetime, "%d.%m.%Y %H:%M o'clock")
  "18.08.2019 22:04 o'clock"

  iex> datetime = ~U[2019-08-18 20:40:15.097740Z] |> Timex.to_datetime("Europe/Berlin")
  iex> ClubHomepage.Extension.CommonTimex.point_of_time(datetime, "%d.%m.%Y %H:%M o'clock")
  "18.08.2019 22:40 o'clock"

  iex> date = ~D[2019-08-18]
  iex> ClubHomepage.Extension.CommonTimex.point_of_time(date, "%d.%m.%Y %H:%M o'clock")
  "18.08.2019 02:00 o'clock"

  iex> date = ~D[2019-08-18]
  iex> ClubHomepage.Extension.CommonTimex.point_of_time(date, "%d.%m.%Y some text")
  "18.08.2019 some text"
  """
  @spec point_of_time(DateTime.t, String.t) :: String.t
  def point_of_time(datetime, format \\ nil) do
    format = point_of_time_format(format)
    {:ok, date_string} =
      datetime
      |> Timex.local()
      |> Timex.format(format, :strftime)
    date_string
  end

  defp point_of_time_format(format) do
    case format do
      nil -> "#{datetime_format()} #{gettext("o_clock")}"
      format -> format
    end
  end

  @doc """
  Converts a timex datetime into a formated string.

  ##Example usage
  iex> ClubHomepage.Extension.CommonTimex.timex_datetime_to_string(~U[2019-08-18 20:04:05.894867Z], "%d.%m.%Y %H:%M")
  "18.08.2019 20:04"
  """
  @spec timex_datetime_to_string(DateTime.t, String.t) :: String.t
  def timex_datetime_to_string(datetime, format) do
    {:ok, date_string} = Timex.format(datetime, format, :strftime)
    date_string
  end

  @doc """

  ## Example usage
  iex> datetime = ~U[2019-08-18 20:04:05.894867Z]
  iex> ClubHomepage.Extension.CommonTimex.to_timex_ecto_date(datetime)
  ~D[2019-08-18]

  iex> datetime = ~U[2019-08-18 20:40:15.097740Z] |> Timex.to_datetime("Europe/Berlin")
  iex> ClubHomepage.Extension.CommonTimex.to_timex_ecto_date(datetime)
  ~D[2019-08-18]

  iex> date = ~D[2019-08-18]
  iex> ClubHomepage.Extension.CommonTimex.to_timex_ecto_date(date)
  ~D[2019-08-18]
  """
  @spec to_timex_ecto_date(Timex.Types.valid_datetime() | DateTime.t | Date.t) :: Date.t
  def to_timex_ecto_date(timex_datetime) do
    #{:ok, timex_ecto_date} = Timex.Ecto.Date.cast(timex_datetime)
    #timex_ecto_date
    Timex.to_date(timex_datetime)
  end

  @doc """

  ## Example usage
  iex> datetime = ~U[2019-08-18 20:04:05.894867Z]
  iex> ClubHomepage.Extension.CommonTimex.to_timex_ecto_datetime(datetime)
  ~U[2019-08-18 20:04:05.894867Z]

  iex> datetime = ~N[2019-08-18 22:04:05]
  iex> ClubHomepage.Extension.CommonTimex.to_timex_ecto_datetime(datetime)
  ~U[2019-08-18 22:04:05Z]
  """
  @spec to_timex_ecto_datetime(Timex.Types.valid_datetime() | DateTime.t) :: DateTime.t
  def to_timex_ecto_datetime(timex_datetime) do
    #{:ok, timex_ecto_datetime} = Timex.Ecto.DateTime.cast(timex_datetime)
    #timex_ecto_datetime
    Timex.to_datetime(timex_datetime)
  end

  @doc """
  Returns the current timezone.

  ## Example usage
  iex> ClubHomepage.Extension.CommonTimex.current_timezone().full_name
  "Europe/Berlin"
  """
  @spec current_timezone() :: Timex.TimezoneInfo.t
  def current_timezone() do
    Timex.Timezone.get(Timex.Timezone.Local.lookup, Timex.local)
  end

  @doc """
  Converts a (native) datetime into a local datetime.

  ## Example usage
  iex> datetime = ~U[2016-07-18 14:30:00Z]
  iex> ClubHomepage.Extension.CommonTimex.utc_to_local_datetime(datetime) |> to_string
  "2016-07-18 16:30:00+02:00 CEST Europe/Berlin"

  iex> datetime = ~N[2016-07-18 14:30:00]
  iex> ClubHomepage.Extension.CommonTimex.utc_to_local_datetime(datetime) |> to_string
  "2016-07-18 14:30:00+02:00 CEST Europe/Berlin"
  """
  @spec utc_to_local_datetime(DateTime.t) :: DateTime.t
  def utc_to_local_datetime(native_or_datetime) do
    Timex.to_datetime(native_or_datetime, current_timezone())
  end
end
