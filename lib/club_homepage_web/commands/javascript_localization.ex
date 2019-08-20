defmodule ClubHomepage.Web.JavascriptLocalization do
  @moduledoc """
  This module holds calculations around birthdays.
  """

  # import Plug.Conn
  import ClubHomepage.Web.Gettext
  import ClubHomepage.Web.Localization

  # def init(_opts) do
  #   nil
  # end

  # def call(conn, _) do
  #   assign(conn, :javascript_localization, run)
  # end

  @doc """
  Returns the javascript localization configuration.
  """
  @spec run() :: Map
  def run() do
    %{
      locale: locale(),
      date_format: date_format(),
      datetime_format: datetime_format(),
      today: gettext("today"),
      clear_selection: gettext("clear_selection"),
      close: gettext("close"),
      select_month: gettext("select_month"),
      previous_month: gettext("previous_month"),
      next_month: gettext("next_month"),
      select_year: gettext("select_year"),
      previous_year: gettext("previous_year"),
      next_year: gettext("next_year"),
      select_decade: gettext("select_decade"),
      previous_decade: gettext("previous_decade"),
      next_decade: gettext("next_decade"),
      previous_century: gettext("previous_century"),
      next_century: gettext("next_century"),
      select_time: gettext("select_time")
    }
  end

  defp locale do
    Application.get_env(:club_homepage, ClubHomepage.Web.Gettext)[:default_locale]
    |> String.downcase
  end
end
