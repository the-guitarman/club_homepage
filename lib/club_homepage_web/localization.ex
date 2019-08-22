defmodule ClubHomepageWeb.Localization do
  import ClubHomepageWeb.Gettext

  @doc """
  Returns the current local abbreviation.

  ## Example usage
  iex> ClubHomepageWeb.Localization.current_locale()
  "en"
  """
  @spec current_locale :: String
  def current_locale do
    Gettext.get_locale(ClubHomepageWeb.Gettext)
  end

  @doc """
  Returns the localized date format.

  ## Example usage
  iex> ClubHomepageWeb.Localization.date_format()
  "%Y-%m-%d"

  iex> ClubHomepageWeb.Localization.date_format("%Y")
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
  iex> ClubHomepageWeb.Localization.datetime_format()
  "%Y-%m-%d %H:%M"

  iex> ClubHomepageWeb.Localization.datetime_format("%H")
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
  iex> ClubHomepageWeb.Localization.time_format()
  "%H:%M"

  iex> ClubHomepageWeb.Localization.time_format("%H")
  "%H"
  """
  def time_format, do: time_format(nil)
  def time_format(nil) do
    gettext("time_format")
  end
  def time_format(format), do: format
end
