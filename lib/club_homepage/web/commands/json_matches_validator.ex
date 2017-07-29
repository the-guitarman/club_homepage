defmodule ClubHomepage.Web.JsonMatchesValidator do
  @moduledoc """
  This module creates a changeset and validates a json string for its schema and content. The changeset could be used with a form_for in the frontend to show te errors.
  """

  alias ClubHomepage.Match
  alias Ecto.Changeset

  @doc """
  Returns a changeset. If params includes a json it validates it. Without a parameters it returns an empty changeset.
  """
  @spec changeset() :: Ecto.Changeset
  @spec changeset(List, Atom, Map) :: Ecto.Changeset
  def changeset do
    new_changeset()
    |> set_changeset_data
    |> set_changeset_model
  end
  def changeset(params) when is_map(params) do
    new_changeset()
    |> set_changeset_changes(params)
    |> set_changeset_params(params)
    |> set_changeset_data
    |> set_changeset_model
  end
  def changeset(required_fields, json_field, params) do
    new_changeset(required_fields, params)
    |> validate_json(json_field, params)
    |> set_changeset_changes(params)
    |> set_changeset_params(params)
    |> set_changeset_valid
    |> set_changeset_action
    |> set_changeset_data
    |> set_changeset_model
  end

  defp set_changeset_changes(change_set, params) do
    %Changeset{change_set | changes: params}
  end

  defp set_changeset_params(change_set, params) do
    %Changeset{change_set | params: params}
  end

  defp set_changeset_valid(change_set) do
    %Changeset{change_set | valid?: Enum.count(change_set.errors) == 0}
  end

  defp set_changeset_action(change_set) do
    action = 
      case Enum.count(change_set.errors) do
        0 -> nil
        _ -> "errors"
      end
    %Changeset{change_set | action: action}
  end

  defp set_changeset_data(changeset) do
    %Changeset{changeset | data: %Match{}}
  end

  defp set_changeset_model(changeset) do
    # %Changeset{changeset | model: Match}
    changeset
  end

  defp validate_json(change_set, json_field, params) do
    value = params[string(json_field)]
    cond do
      value == nil  -> add_error(change_set, json_field, "is empty")
      String.trim(value) == ""  -> add_error(change_set, json_field, "is empty")
      true -> parse(change_set, atom(json_field), value)
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
            "items" => %{
              "type" => "object",
              "properties" => %{
                "competition" => %{"type" => "string"},
                "start_at" => %{"type" => "string"},
                "home"     => %{"type" => "string"},
                "guest"    => %{"type" => "string"}
              },
              "required" => ["start_at", "home", "guest"]
            }
          }
        },
        "required" => ["team_name", "matches"]
      }
      |> ExJsonSchema.Schema.resolve
      |> ExJsonSchema.Validator.validate(map)
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

  defp validate_json_content(changeset, field, %{"team_name" => team_name, "matches" => matches} = _map) when is_list(matches) do
    ret = 
    changeset
    |> validate_json_matches(field, matches)
    |> validate_string_value(field, "team_name", team_name)
    ret
  end
  defp validate_json_content(change_set, _field, _map), do: change_set

  defp validate_json_matches(changeset, _field, []), do: changeset
  defp validate_json_matches(changeset, field, [match | rest_matches] = matches) when is_list(matches) do
    changeset
    |> validate_json_match(field, match)
    |> validate_json_matches(field, rest_matches)
  end

  defp validate_json_match(changeset, field, %{"competition" => competition, "start_at" => start_at, "guest" => guest, "home" => home}) do
    changeset
    |> validate_string_value(field, "competition", competition)
    |> validate_start_at(field, "start_at", start_at)
    |> validate_string_value(field, "home", home)
    |> validate_string_value(field, "guest", guest)
  end
  defp validate_json_match(changeset, field, _) do
    add_error(changeset, field, "A match requires start_at, home and guest fields.")
  end

  defp validate_start_at(change_set, field, key, value) when is_binary(value) do
    case to_timex_date_format(value) do
      {:ok, _datetime} -> change_set
      {:error, error}  -> add_error(change_set, field, "#{key}: #{error}")
    end
  end
  defp validate_start_at(change_set, field, key, _map) do
    add_error(change_set, field, "#{key}: missing or wrong type")
  end

  def to_timex_date_format(date_time_string) do
    case Timex.parse(String.trim(date_time_string), "{ISO:Extended}") do
      {:ok, datetime} -> {:ok, Timex.local(datetime)}
      {:error, error} -> {:error, error}
    end
  end

  defp validate_string_value(change_set, field, key, value) when is_binary(value) do
   case String.length(value) do
     0 -> validate_string_value(change_set, field, key, nil) 
     _ -> change_set
   end
  end
  defp validate_string_value(change_set, field, key, _value) do
    add_error(change_set, field, "#{key}: missing or wrong type")
  end

  defp add_error(change_set, field, value) do
    Changeset.add_error(change_set, field, value)
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
    %Changeset{action: nil, valid?: true, changes: %{}, params: nil, errors: []}
  end
  defp new_changeset(required_fields, params) do
    types = %{season_id: :integer, team_id: :integer, json: :string}
    Changeset.cast({params, types}, params, required_fields)
  end
end
