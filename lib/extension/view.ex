defmodule Extension.View do
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

  def timex_date_input(%{model: model, params: params} = form, field, opts \\ []) do
    field_name = Atom.to_string(field)
    case Map.fetch(params, field_name) do
      {:ok, nil} -> nil
      {:ok, timex_datetime} -> 
        {:ok, date_string} = Timex.DateFormat.format(timex_datetime, "%d.%m.%Y", :strftime)
        params = Map.put(params, field_name, date_string)
        form = Map.put(form, :params, params)
      :error -> Map.get(model, field)
    end
    Phoenix.HTML.Form.text_input(form, field, opts)
  end
end