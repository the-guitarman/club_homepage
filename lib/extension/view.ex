defmodule ClubHomepage.Extension.View do
  alias Phoenix.HTML
  alias Phoenix.HTML.Form
  alias Phoenix.HTML.Tag

  import ClubHomepage.ErrorHelpers 
  import ClubHomepage.Gettext
  import ClubHomepage.Extension.CommonTimex

  def current_link(_conn, _module, [] = actions) when is_list(actions), do: ""
  def current_link(conn, module, [head | tail] = actions) when is_list(actions) do
    current_link_class(conn, module, head) <> " " <> current_link(conn, module, tail)
  end

  def current_link(conn, module, action) when is_atom(action) do
    current_link_class(conn, module, action)
  end

  def current_link(conn, module, action) when is_bitstring(action) do
    current_link_class(conn, module, String.to_atom(action))
  end

  defp current_link_class(conn, module, action) do
    case Phoenix.Controller.controller_module(conn) == module && Phoenix.Controller.action_name(conn) == action do
      true -> "active"
      _ -> ""
    end
  end




  def copyright do
    start_year = 2016
    %{year: current_year} = Timex.Date.local
    year = 
      cond do
        start_year == current_year -> "#{start_year}"
        true -> "#{start_year} - #{current_year}"
      end
    "© Copyright #{year}"
  end

  def current_domain(conn) do
    case conn.port do
      80 -> conn.host
      _ -> "#{conn.host}:#{conn.port}"
    end
  end




  def timex_date_input_format do
    "%d.%m.%Y"
  end

  def js_date_input_format(divider \\ ".") do
    timex_date_input_format
    |> String.replace("%", "")
    |> String.split(divider)
    |> Enum.map(fn(el) -> if el == "Y", do: "#{el}#{el}#{el}#{el}", else: "#{el}#{el}" |> String.upcase() end)
    |> Enum.join(divider)
  end

  def timex_date_input(form, field, opts \\ []) do
    opts = Keyword.put(opts, :"data-format", js_date_input_format)
    timex_input(form, field, timex_date_input_format, opts)
  end

  def timex_time_input_format do
    "%H:%M"
  end

  def js_time_input_format(divider \\ ":") do
    parts = 
      timex_time_input_format
      |> String.replace("%", "")
      |> String.split(divider)
      |> Enum.map(fn(el) -> String.upcase("#{el}#{el}") end)

    [String.upcase(List.first(parts)), String.downcase(List.last(parts))]
    |> Enum.join(divider)
  end

  def timex_datetime_input_format do
    "#{timex_date_input_format} #{timex_time_input_format}"
  end

  def js_datetime_input_format do
    "#{js_date_input_format} #{js_time_input_format}"
  end

  def timex_datetime_input(form, field, opts \\ []) do
    opts = Keyword.put(opts, :"data-format", js_datetime_input_format)
    timex_input(form, field, timex_datetime_input_format, opts)
  end

  defp timex_input(%{model: model, params: params} = form, field, format, opts) do
    field_name = Atom.to_string(field)
    case Map.fetch(params, field_name) do
      {:ok, nil} ->
        nil
      {:ok, timex_datetime} -> 
        date_string = timex_datetime_to_string(timex_datetime, format)
        params = Map.put(params, field_name, date_string)
        form = Map.put(form, :params, params)
      :error ->
        timex_datetime = Map.get(model, field)
        if timex_datetime do
          date_string = timex_datetime_to_string(timex_datetime, format)
          params = Map.put(params, field_name, date_string)
          form = Map.put(form, :params, params)
        end
    end
    field_css_class = 
      case String.contains?(format, ["%H", "%M"]) do
        true -> "datetime"
        false -> "date"
      end
    Tag.content_tag(:div, class: "input-group #{field_css_class}") do
      button = Tag.content_tag(:span, class: "input-group-addon") do
        Tag.content_tag(:i, "", class: "glyphicon glyphicon-calendar")
      end
      HTML.raw(HTML.safe_to_string(Form.text_input(form, field, opts)) <> HTML.safe_to_string(button))
    end
  end



 
  def show_form_errors(changeset, f) do
    if changeset.action do
      Tag.content_tag(:div, class: "alert alert-danger") do
        p_tag = Tag.content_tag(:p) do
          gettext("form_input_errors_notice")
        end
        ul_tag = Tag.content_tag(:ul) do
          for {attr, message} <- f.errors do
            Tag.content_tag(:li) do
              Form.humanize(attr) <> " " <> translate_error(message)
            end
          end
        end
        HTML.raw(HTML.safe_to_string(p_tag) <> HTML.safe_to_string(ul_tag))
      end
    end
  end

  def required_field(form, field) do
    case form.model.__struct__.required_field?(field) do
      true  -> " *"
      false -> ""
    end
  end
end
