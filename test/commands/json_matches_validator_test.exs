defmodule ClubHomepage.JsonMatchesValidatorTest do
  use ClubHomepage.ModelCase
  use ExUnit.Case
  doctest ClubHomepage.JsonMatchesValidator

  alias ClubHomepage.JsonMatchesValidator

  @params %{"json" => "{\r\n  \"team_name\": \"Name meiner Vereinsmannschaft\",\r\n  \"matches\": [\r\n    {\r\n      \"competition\": \"League 1\",\r\n      \"start_at\": \"Sonntag, 13.03.2016 - 12:00 Uhr\",\r\n      \"home\": \"Name der gegnerischen Mannschaft 1\",\r\n      \"guest\": \"Name meiner Vereinsmannschaft\"\r\n    },\r\n    {\r\n      \"competition\": \"Super Cup\",\r\n      \"start_at\": \"Sonntag, 03.04.2016 - 14:00 Uhr\",\r\n      \"home\": \"Name meiner Vereinsmannschaft\",\r\n      \"guest\": \"Name def gegnerischen Mannschaft 2\"\r\n    }\r\n  ]\r\n}"}

  test "get an empty changeset" do
    changeset = JsonMatchesValidator.changeset
    assert changeset.action == nil
    assert changeset.valid? == true
    assert changeset.changes == %{}
    assert changeset.params == nil
    assert changeset.errors == []
  end

  test "get a changeset for valid json" do
    changeset = JsonMatchesValidator.changeset([:json], :json, @params)
    assert changeset.action == nil
    assert changeset.valid? == true
    assert changeset.changes == @params
    assert changeset.params == @params
    assert changeset.errors == []
  end

  test "get a changeset for json with team_name is missing" do
    params = delete_key_from_json(@params, "team_name")
    changeset = JsonMatchesValidator.changeset([:json], :json, params)
    assert changeset.action == "errors"
    assert changeset.valid? == false
    assert changeset.changes == params
    assert changeset.params == params
    assert changeset.errors == [json: "#: Required property team_name was not present."]
  end

  test "get a changeset for json with matches is missing" do
    params = delete_key_from_json(@params, "matches")
    changeset = JsonMatchesValidator.changeset([:json], :json, params)
    assert changeset.action == "errors"
    assert changeset.valid? == false
    assert changeset.changes == params
    assert changeset.params == params
    assert changeset.errors == [json: "#: Required property matches was not present."]
  end

  test "get a changeset for json with matches[0][start_at] is missing" do
    params = delete_key_from_json(@params, ["matches", "start_at"])
    changeset = JsonMatchesValidator.changeset([:json], :json, params)
    assert changeset.action == "errors"
    assert changeset.valid? == false
    assert changeset.changes == params
    assert changeset.params == params
    assert changeset.errors == [json: "#/matches/0: Required property start_at was not present."]
  end

  test "get a changeset for json with matches[0][home] is missing" do
    params = delete_key_from_json(@params, ["matches", "home"])
    changeset = JsonMatchesValidator.changeset([:json], :json, params)
    assert changeset.action == "errors"
    assert changeset.valid? == false
    assert changeset.changes == params
    assert changeset.params == params
    assert changeset.errors == [json: "#/matches/0: Required property home was not present."]
  end

  test "get a changeset for json with matches[0][guest] is missing" do
    params = delete_key_from_json(@params, ["matches", "guest"])
    changeset = JsonMatchesValidator.changeset([:json], :json, params)
    assert changeset.action == "errors"
    assert changeset.valid? == false
    assert changeset.changes == params
    assert changeset.params == params
    assert changeset.errors == [json: "#/matches/0: Required property guest was not present."]
  end

  test "get a changeset for json with matches key has wrong value" do
    params = set_wrong_value_json(@params, "matches")
    changeset = JsonMatchesValidator.changeset([:json], :json, params)
    assert changeset.action == "errors"
    assert changeset.valid? == false
    assert changeset.changes == params
    assert changeset.params == params
    assert changeset.errors == [json: "#/matches: Type mismatch. Expected Array but got Integer."]
  end

  test "get a changeset for json with team_name key has wrong value" do
    params = set_wrong_value_json(@params, "team_name")
    changeset = JsonMatchesValidator.changeset([:json], :json, params)
    assert changeset.action == "errors"
    assert changeset.valid? == false
    assert changeset.changes == params
    assert changeset.params == params
    assert changeset.errors == [json: "team_name: missing or wrong type", json: "#/team_name: Type mismatch. Expected String but got Integer."]
  end

  test "get a changeset for json with matches[0][start_at] has wrong value" do
    params = set_wrong_value_json(@params, ["matches", "start_at"])
    changeset = JsonMatchesValidator.changeset([:json], :json, params)
    assert changeset.action == "errors"
    assert changeset.valid? == false
    assert changeset.changes == params
    assert changeset.params == params
    assert changeset.errors == [json: "#/matches/0/start_at: Type mismatch. Expected String but got Integer."]
  end

  test "get a changeset for json with matches[0][home] has wrong value" do
    params = set_wrong_value_json(@params, ["matches", "home"])
    changeset = JsonMatchesValidator.changeset([:json], :json, params)
    assert changeset.action == "errors"
    assert changeset.valid? == false
    assert changeset.changes == params
    assert changeset.params == params
    assert changeset.errors == [json: "#/matches/0/home: Type mismatch. Expected String but got Integer."]
  end

  test "get a changeset for json with matches[0][guest] has wrong value" do
    params = set_wrong_value_json(@params, ["matches", "guest"])
    changeset = JsonMatchesValidator.changeset([:json], :json, params)
    assert changeset.action == "errors"
    assert changeset.valid? == false
    assert changeset.changes == params
    assert changeset.params == params
    assert changeset.errors == [json: "#/matches/0/guest: Type mismatch. Expected String but got Integer."]
  end

  defp delete_key_from_json(params, [key | [key2]]) do
    {:ok, map} = JSON.decode(params["json"])
    [el1, rest] = map[key]
    new_map = Map.put(map, key, [Map.delete(el1, key2), rest])
    {:ok, json} = JSON.encode(new_map)
    %{"json" => json}
  end
  defp delete_key_from_json(params, key) do
    {:ok, map} = JSON.decode(params["json"])
    {:ok, json} = JSON.encode(Map.delete(map, key))
    %{"json" => json}
  end

  defp set_wrong_value_json(params, [key | [key2]]) do
    {:ok, map} = JSON.decode(params["json"])
    [el1, rest] = map[key]
    new_map = Map.put(map, key, [Map.put(el1, key2, 1), rest])
    {:ok, json} = JSON.encode(new_map)
    %{"json" => json}
  end
  defp set_wrong_value_json(params, key) do
    {:ok, map} = JSON.decode(params["json"])
    {:ok, json} = JSON.encode(Map.put(map, key, 1))
    %{"json" => json}
  end
end
