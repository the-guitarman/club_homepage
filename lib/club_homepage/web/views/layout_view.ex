defmodule ClubHomepage.Web.LayoutView do
  use ClubHomepage.Web, :view

  import Number.Currency

  def my_payment_lists_popover_content(conn, payment_lists) do
    links = ["<a href=\"#{payment_list_path(conn, :new)}\" class=\"list-group-item css-new-item-link\"><span class=\"glyphicon glyphicon-plus-sign\"></span> #{gettext("create_payment_list_button_text")}</a>" | payment_list_link(conn, payment_lists)]
    "<div class=\"list-group\">" <> Enum.join(links) <> "</div>"
  end

  defp payment_list_link(_conn, []), do: []
  defp payment_list_link(conn, [payment_list | payment_lists]) do
    ["<a href=\"#{payment_list_path(conn, :show, payment_list)}\" class=\"list-group-item css-payment-list-link\"><span>#{payment_list.title}<br /><span class=\"costs\">#{number_to_currency(payment_list.price_per_piece)}/#{gettext("piece_abbreviation")}</span></span><span class=\"badge\">#{payment_list.number_of_debitors}</span></a>" |  payment_list_link(conn, payment_lists)]
  end

  def weather_data_popover_content(weather_data) do
    {:ok, date_string} = Timex.format(weather_data[:created_at], datetime_format(), :strftime)
<<<<<<< HEAD:web/views/layout_view.ex
    "<div class=\"popover-content-box\">
      <div class=\"row\">
        <div class=\"col-xs-12 text-center\">#{date_string} #{gettext("o_clock")}</div>
        <div class=\"col-xs-12 text-center\">#{weather_data[:weather]}<br /><br /></div>
=======
    "<div class=\"row popover-content-box\">
      <div class=\"col-xs-12 text-center\">#{date_string} #{gettext("o_clock")}</div>
      <div class=\"col-xs-12 text-center\">#{weather_data[:weather]}<br /><br /></div>
>>>>>>> phx_1_3_rc:lib/club_homepage/web/views/layout_view.ex

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
      Gettext.dgettext(ClubHomepage.Web.Gettext, "additionals", "wind_direction_abbreviation_#{weather_data[:wind_direction_abbreviation]}")
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
    ClubHomepage.Web.JavascriptLocalization.run
    |> to_json
  end

  def to_json(object) do
    case JSON.encode(object) do
      {:ok, json} -> json
      _           -> ""
    end
  end
end
