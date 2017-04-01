defmodule ClubHomepage.LayoutView do
  use ClubHomepage.Web, :view

  def weather_data_popover_content(weather_data) do
    {:ok, date_string} = Timex.format(weather_data[:created_at], datetime_format(), :strftime)
    "<div class=\"popover-content-box\">
      <div class=\"row\">
        <div class=\"col-xs-12 text-center\">#{date_string} #{gettext("o_clock")}</div>
        <div class=\"col-xs-12 text-center\">#{weather_data[:weather]}<br /><br /></div>

        <div class=\"col-xs-6\"><small>#{gettext("temperature")}:</small></div>
        <div class=\"col-xs-6\">#{weather_data[:temperature]}</div>

        <div class=\"col-xs-6\"><small>Wind:</small></div>
        <div class=\"col-xs-6\">#{weather_data[:wind_speed]} #{wind_direction_abbrevation(weather_data)}</div>

        <div class=\"col-xs-6\"><small>#{gettext("humidity")}:</small></div>
        <div class=\"col-xs-6\">#{weather_data[:humidity_in_percent]} %</div>

        <div class=\"col-xs-6\"><small>#{gettext("air_pressure")}:</small></div>
        <div class=\"col-xs-6\">#{weather_data[:pressure_in_hectopascal]} hPa</div>
      </div>
    </div>"
  end

  defp wind_direction_abbrevation(weather_data) do
    if weather_data[:wind_direction_abbreviation] != "" do
      Gettext.dgettext(ClubHomepage.Gettext, "additionals", "wind_direction_abbreviation_#{weather_data[:wind_direction_abbreviation]}")
    end
  end




  def birthdays_popover_content(birthdays) do
    date_keys = Keyword.keys(birthdays)
    Enum.map_join(birthday_dates(date_keys, birthdays), &(&1))
    |> birthday_list_group
  end

  defp birthday_list_group([]), do: ""
  defp birthday_list_group(elements) do
    "<div class=\"list-group css-birthdays\">#{elements}</div>"
  end

  defp birthday_dates([], _), do: []
  defp birthday_dates([date_key | date_keys], birthdays) do
    {:ok, date} = Timex.parse(Atom.to_string(date_key), "%Y-%m-%d", :strftime)
    {:ok, date} = Timex.format(date, date_format(), :strftime)
    [[date_row(date) | birthdays(birthdays[date_key])] | birthday_dates(date_keys, birthdays)]
    |> Enum.flat_map(fn(el) -> el end)
  end

  defp date_row(date) do
    "<div class=\"list-group-item disabled text-center\">#{date}</div>"
  end

  defp birthdays([]), do: []
  defp birthdays([birthday | birthdays]) do
    [birthday_row(birthday) | birthdays(birthdays)]
  end

  defp birthday_row(birthday) do
    "<div class=\"list-group-item text-center\">#{birthday}</div>"
  end




  def javascript_localization_options do
    ClubHomepage.JavascriptLocalization.run
    |> to_json
  end

  def to_json(object) do
    case JSON.encode(object) do
      {:ok, json} -> json
      _           -> ""
    end
  end
end
