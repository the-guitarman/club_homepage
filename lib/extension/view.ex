defmodule ClubHomepage.Extension.View do
  alias Phoenix.HTML
  alias Phoenix.HTML.Form
  alias Phoenix.HTML.Tag

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




  def current_domain(conn) do
    case conn.port do
      80 -> conn.host
      _ -> "#{conn.host}:#{conn.port}"
    end
  end




  def timex_date_input(form, field, opts \\ []) do
    timex_input(form, field, "%d.%m.%Y", opts)
  end

  def timex_datetime_input(form, field, opts \\ []) do
    timex_input(form, field, "%d.%m.%Y %H:%M", opts)
  end

  defp timex_input(%{model: model, params: params} = form, field, format, opts) do
    field_name = Atom.to_string(field)
    case Map.fetch(params, field_name) do
      {:ok, nil} -> nil
      {:ok, timex_datetime} -> 
        {:ok, date_string} = Timex.DateFormat.format(timex_datetime, format, :strftime)
        params = Map.put(params, field_name, date_string)
        form = Map.put(form, :params, params)
      :error -> Map.get(model, field)
    end
    field_css_class = case String.contains?(format, ["%H", "%M"]) do
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
end
