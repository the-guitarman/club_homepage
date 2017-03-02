defmodule ClubHomepage.Localization do
  import ClubHomepage.Gettext

  @doc """
  Returns the localized date format.

  ## Example usage
  iex> ClubHomepage.Localization.date_format()
  "%Y-%m-%d"

  iex> ClubHomepage.Localization.date_format("%Y")
  "%Y"
  """
  def date_format, do: date_format(nil)
  def date_format(nil) do
    gettext("date_format")
  end
  def date_format(format), do: format

  @doc """
  Returns the localized date format.

  ## Example usage
  iex> ClubHomepage.Localization.datetime_format()
  "%Y-%m-%d %H:%M"

  iex> ClubHomepage.Localization.datetime_format("%H")
  "%H"
  """
  def datetime_format, do: datetime_format(nil)
  def datetime_format(nil) do
    gettext("date_and_time_format")
  end
  def datetime_format(format), do: format

  @doc """
  Returns the localized date format.

  ## Example usage
  iex> ClubHomepage.Localization.time_format()
  "%H:%M"

  iex> ClubHomepage.Localization.time_format("%H")
  "%H"
  """
  def time_format, do: time_format(nil)
  def time_format(nil) do
    gettext("time_format")
  end
  def time_format(format), do: format
end
