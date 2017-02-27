defmodule ClubHomepage.Localization do
  import ClubHomepage.Gettext

  def date_format, do: date_format(nil)
  def date_format(nil) do
    gettext("date_format")
  end
  def date_format(format), do: format

  def datetime_format, do: datetime_format(nil)
  def datetime_format(nil) do
    gettext("date_and_time_format")
  end
  def datetime_format(format), do: format

  def time_format, do: time_format(nil)
  def time_format(nil) do
    gettext("time_format")
  end
  def time_format(format), do: format
end
