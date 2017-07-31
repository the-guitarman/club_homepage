defmodule ClubHomepage.Extension.CommonTimex do
  import ClubHomepage.Web.Gettext
  import ClubHomepage.Web.Localization

  def point_of_time(datetime, format \\ "#{datetime_format()} #{gettext("o_clock")}") do
    {:ok, date_string} =
      datetime
    |> Timex.local
    |> Timex.format(format, :strftime)
    date_string
  end

  def timex_datetime_to_string(datetime, format) do
    {:ok, date_string} = Timex.format(datetime, format, :strftime)
    date_string
  end

  def to_timex_ecto_date(timex_datetime) do
    {:ok, timex_ecto_date} = Timex.Ecto.Date.cast(timex_datetime)
    timex_ecto_date
  end

  def to_timex_ecto_datetime(timex_datetime) do
    {:ok, timex_ecto_datetime} = Timex.Ecto.DateTime.cast(timex_datetime)
    timex_ecto_datetime
  end
end
