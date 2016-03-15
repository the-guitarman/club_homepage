defmodule ClubHomepage.Extension.CommonTimex do
  def timex_datetime_to_string(datetime, format) do
    {:ok, date_string} = Timex.DateFormat.format(datetime, format, :strftime)
    date_string
  end

  def to_timex_ecto_datetime(timex_datetime) do
    {:ok, timex_ecto_datetime} = Timex.Ecto.DateTime.cast(timex_datetime)
    timex_ecto_datetime
  end
end
