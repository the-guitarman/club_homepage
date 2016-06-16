defmodule ClubHomepage.ModelValidator do
  @moduledoc """
  This is a workaround, because Ecto.Changeset.unique_constraint/3 doesn't work with sqlite. This module checks the repo adapter. If it's Sqlite.Ecto, it will fire a query against the database to check the uniqueness of the given field or fields list. Otherwise it will simply use Ecto.Changeset.unique_constraint/3.
  """

  #import ClubHomepage.Gettext

  alias ClubHomepage.Repo
  alias Ecto.Changeset

  @doc """
  Checks for a unique constraint in the given field or field list.
  Please see: https://hexdocs.pm/ecto/Ecto.Changeset.html#unique_constraint/3
  """
  @spec validate_uniqueness( Ecto.Changeset, Atom | List, Keyword ) :: Ecto.Changeset
  def validate_uniqueness(model, key), do: validate_uniqueness(model, key, %{})
  def validate_uniqueness(model, key, params) do
    case is_sqlite_adapter? do
      true ->
        model
        |> get_value_to_validate(key)
        |> check_uniqueness_of_value(key)
      _ ->
        unique_constraint(model, key, params)
    end
  end

  def foreign_key_constraint(model, key), do: foreign_key_constraint(model, key, [])
  def foreign_key_constraint(model, key, params) do
    case is_sqlite_adapter? do
      true ->
        foreign_model = extract_model_from_foreign_key(key)
        foreign_changeset = foreign_model.changeset(foreign_model.__struct__)
        {state, _, value} = get_value_to_validate(model, key)
        check_for_existence_of_value({state, foreign_changeset, value}, model, key)
      _ -> 
        foreign_key_constraint(model, key, params)
    end
  end

  def is_sqlite_adapter? do 
    case Application.get_env(:club_homepage, Repo)[:adapter] do
      Sqlite.Ecto -> true
      _ -> false
    end
  end

  defp extract_model_from_foreign_key(key) do
    model_name = key
      |> Atom.to_string
      |> String.replace(~r/_id$/, "")
      |> String.split("_")
      |> Enum.map(fn(s) -> String.capitalize(s) end)
      |> Enum.join("")
    String.to_existing_atom("Elixir.ClubHomepage." <> model_name)
  end

  defp unique_constraint(model, key, params) when is_atom(key) do
    Changeset.unique_constraint(model, key, params)
  end
  defp unique_constraint(model, [key | _tail] = keys, params) when is_list(keys) do
    Changeset.unique_constraint(model, key, params)
  end

  defp get_value_to_validate(model, key) when is_atom(key) do
    case model.changes[key] do
      nil   -> {:error, model, nil}
      value ->
        {:ok, model, value}
    end
  end
  defp get_value_to_validate(_, []), do: []
  defp get_value_to_validate(model, [key | tail] = keys) when is_list(keys) do
    case get_value_to_validate(model, key) do
      {_, _, nil} -> {:error, model, nil}
      {_, _, value} ->
        {:ok, model, List.flatten([value | values_to_validate(model, tail)])}
    end
  end

  defp values_to_validate(_model, []), do: []
  defp values_to_validate(model, [key | tail] = keys) when is_list(keys) do
    value =
      case get_value_to_validate(model, key) do
        {_, _, nil} -> []
        {_, _, val} -> val
      end
    [value | values_to_validate(model, tail)]
  end

  defp check_uniqueness_of_value({:error, model, nil}, _key), do: model
  defp check_uniqueness_of_value({:ok, model, value}, key) when is_atom(key) do
    case Repo.get_by(model.model.__struct__, Keyword.new([{key, value}])) do
      nil -> model
      _   -> Changeset.add_error(model, key, "already exists")
    end
  end
  defp check_uniqueness_of_value({:ok, model, values}, keys) when is_list(keys) do
    if Enum.count(keys) == Enum.count(values) do
      check_uniqueness_of_values(model, keys, values)
    else
      model
    end
  end

  defp check_uniqueness_of_values(model, keys, values) do
    conditions = Enum.zip(keys, values) |> Enum.into(%{})
    case Repo.get_by(model.model.__struct__, conditions) do
      nil -> model
      _   -> Changeset.add_error(model, get_model_name(model), "already exists")
    end
  end

  defp check_for_existence_of_value({:error, _foreign_changeset, _value}, model, _key), do: model
  defp check_for_existence_of_value({:ok, foreign_changeset, value}, model, key) when is_atom(key) do
    case Repo.get_by(foreign_changeset.model.__struct__, Keyword.new([{:id, value}])) do
      nil -> Changeset.add_error(model, key, "does not exist")
      _   -> model
    end
  end

  defp get_model_name(model) do
    Atom.to_string(model.model.__struct__)
    |> String.split(".", trim: true)
    |> Enum.reverse
    |> Enum.at(0)
    |> String.capitalize
  end
end
