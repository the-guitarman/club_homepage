defmodule ClubHomepageWeb.LayoutView do
  use ClubHomepageWeb, :view

  import Number.Currency

  def background_image_cls() do
    #if asset_path?("/background_01.jpg") do
    #end
    "background-image-01"
  end

  def hoster?() do
    not(is_nil(Application.get_env(:club_homepage, :hoster)))
  end

  def hoster() do
    params = Application.get_env(:club_homepage, :hoster)
    logo_or_name = "Hosted by " <> 
      case asset_path?("/images/" <> params[:logo]) do
        true -> "<img src=\"/images/" <> params[:logo] <> "\" alt=\"\" />"
        _ -> params[:name]
      end

    link_or_text =
      case is_nil(params[:href]) do
        true -> logo_or_name
        _ -> "<a class=\"btn btn-de\" href=\"" <> params[:href] <> "\" target=\"_blank\">" <> logo_or_name <> "</a>"
      end

    raw(link_or_text)
  end

  def my_payment_lists_popover_content(conn) do
    payment_lists = conn.assigns[:my_payment_lists]
    payment_list_debitors = conn.assigns[:my_payment_list_debitors]

    links = [payment_list_links(conn, payment_lists) | payment_list_debitor_links(conn, payment_list_debitors)]
    links = ["<a href=\"#{Routes.payment_list_path(conn, :new)}\" class=\"list-group-item css-new-item-link\"><span class=\"glyphicon glyphicon-plus-sign\"></span> #{gettext("create_payment_list_button_text")}</a>" | links]
    "<div class=\"list-group\">" <> Enum.join(links) <> "</div>"
  end

  defp payment_list_links(_conn, []), do: []
  defp payment_list_links(conn, [payment_list | payment_lists]) do
    ["<a href=\"#{Routes.payment_list_path(conn, :show, payment_list)}\" class=\"list-group-item css-payment-list-link\"><span>#{payment_list.title}<br /><span class=\"costs\">#{number_to_currency(payment_list.price_per_piece)}/#{gettext("piece_abbreviation")}</span></span><span class=\"badge\">#{payment_list.number_of_debitors}</span></a>" |  payment_list_links(conn, payment_lists)]
  end

  defp payment_list_debitor_links(_conn, []), do: []
  defp payment_list_debitor_links(conn, [debitor | debitors]) do
    if debitor.number_of_units > 0 do
      payment_list = debitor.payment_list
      owner_and_deputy =
        case debitor.payment_list_deputy do
          nil -> [debitor.payment_list_owner]
          deputy -> [debitor.payment_list_owner, deputy]
        end
        |> Enum.map(fn(user) ->  user_name(user) end)
        |> Enum.join(", ")
        ["<div class=\"js-payment-list\" data-payment-list-id=\"#{payment_list.id}\"><a href=\"#{Routes.payment_list_debitor_path(conn, :show, payment_list, debitor)}\" class=\"list-group-item js-payment-list-debitor css-payment-list-debitor-link\" data-payment-list-debitor-id=\"#{debitor.id}\"><span>#{payment_list.title}<br /><span class=\"costs\">#{number_to_currency(payment_list.price_per_piece)}/#{gettext("piece_abbreviation")}</span><br /><span class=\"costs\">#{gettext("responsible")}: #{owner_and_deputy}</span></span><span class=\"badge background-red\">#{number_to_currency(payment_list.price_per_piece * debitor.number_of_units)}</span></a></div>" | payment_list_debitor_links(conn, debitors)]
    else
      payment_list_debitor_links(conn, debitors)
    end
  end

  def weather_data_popover_content(weather_data) do
    {:ok, date_string} = Timex.format(weather_data[:created_at], datetime_format(), :strftime)
    "<div class=\"row popover-content-box\">
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
      Gettext.dgettext(ClubHomepageWeb.Gettext, "additionals", "wind_direction_abbreviation_#{weather_data[:wind_direction_abbreviation]}")
    end
  end




  def birthdays_popover_content(birthdays) do
    birthdays |> IO.inspect()
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
    ClubHomepageWeb.JavascriptLocalization.run
    |> to_json
  end

  def to_json(object) do
    case JSON.encode(object) do
      {:ok, json} -> json
      _           -> ""
    end
  end
end
