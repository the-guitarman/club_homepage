defmodule ClubHomepage.MatchesJsonValidator do
  alias ClubHomepage.Match
  alias Ecto.Changeset

  def changeset do
    new_changeset
  end
  def changeset(required_fields, json_field, params) do
    change_set =
      new_changeset
      |> Changeset.cast(params, required_fields, ~w())
      |> validate_json(json_field, params)
    %Changeset{change_set | changes: params, params: params, valid?: Enum.count(change_set.errors) == 0}
  end

  defp validate_json(change_set, json_field, params) do
    case params[string(json_field)] do
      nil  -> change_set
      json -> parse(change_set, atom(json_field), json)
    end
  end

  defp parse(change_set, field, json) do
    case JSON.decode(json) do
      {:ok, map} ->
        change_set
        |> validate_json_schema(field, map)
        |> validate_json_content(field, map)
      {:error, {key, message}} -> add_error(change_set, field, "#{key}: #{message}")
      {:error, error} -> add_error(change_set, field, "#{error}")
    end
  end

  defp validate_json_schema(change_set, field, map) do
    result = 
      %{
        "type" => "object",
        "properties" => %{
          "team_name" => %{"type" => "string"},
          "matches"   => %{
            "type"       => "array",
            "properties" => %{
              "start_at" => %{"type" => "string"},
              "home"     => %{"type" => "string"},
              "guest"    => %{"type" => "string"}
            }
          }
        }
      }
      |> ExJsonSchema.Schema.resolve
      |> ExJsonSchema.Validator.validate(map)
    IO.puts "--result"
    IO.inspect result
    case result do
      :ok              -> change_set
      {:error, errors} -> add_error(change_set, field, join_json_schema_errors(errors))
    end
  end

  defp join_json_schema_errors(errors) do
    Enum.map(errors, fn(x) ->
        Tuple.to_list(x)
        |> Enum.reverse
        |> Enum.join(": ")
      end
    ) |> Enum.join(", ")
  end

  defp validate_json_content(change_set, field, %{"team_name" => team_name, "matches" => matches} = _map) do
    for match <- matches do
      change_set = 
        case match do
          %{"start_at" => start_at, "guest" => guest, "home" => home} ->
            change_set
            |> validate_start_at(field, "start_at", start_at)
            |> validate_string_value(field, "home", home)
            |> validate_string_value(field, "guest", guest)
          _ -> add_error(change_set, field, "A match requires start_at, home and guest fields.")
        end
    end
    validate_string_value(change_set, field, "team_name", team_name)
  end
  defp validate_json_content(change_set, _field, _map), do: change_set

  defp validate_start_at(change_set, field, key, value) do
    [_, date_time] = String.split(value, ",")
    result =
      String.strip(date_time)
      |> Timex.DateFormat.parse("%d.%m.%Y - %H:%M Uhr", :strftime)
    case result do
      {:ok, _datetime} -> change_set
      {:error, error}  -> add_error(change_set, field, "#{key}: #{error}")
    end
  end

  defp validate_string_value(change_set, field, key, value) when is_binary(value) do
   case String.length(value) do
     0 -> validate_string_value(change_set, field, key, nil) 
     _ -> change_set
   end
  end
  defp validate_string_value(change_set, field, key, _value) do
    add_error(change_set, field, "#{key}: missing")
  end

  defp add_error(change_set, field, value) do
    %Changeset{change_set | action: "errors"}
    |> Changeset.add_error(field, value)
  end

  defp string(name) when is_binary(name), do: name
  defp string(name) when is_atom(name) do
    Atom.to_string(name)
  end

  defp atom(name) when is_atom(name), do: name
  defp atom(name) when is_binary(name) do
    String.to_atom(name)
  end

  defp new_changeset do
    %Changeset{model: %Match{}}
  end
end
