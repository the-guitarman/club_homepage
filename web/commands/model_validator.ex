defmodule ClubHomepage.ModelValidator do 
  @moduledoc """
  This is a workaround, because Ecto.Changeset.unique_constraint/3 doesn't work with sqlite. This module checks the repo adapter. If it's Sqlite.Ecto, it will fire a query against the database to check the uniqueness of the given field or fields list. Otherwise it will simply use Ecto.Changeset.unique_constraint/3.
  """

  alias ClubHomepage.Repo
  alias Ecto.Changeset

  @doc """
  Checks for a unique constraint in the given field or field list.
  Please see: https://hexdocs.pm/ecto/Ecto.Changeset.html#unique_constraint/3
  """
  @spec validate_uniqueness( Ecto.Changeset, Atom | List, Keyword ) :: Ecto.Changeset
  def validate_uniqueness(model, key, params) do
    case Application.get_env(:club_homepage, Repo)[:adapter] do
      Sqlite.Ecto ->
        model
        |> validate_uniqueness_of(key)
        |> try_to_find_value(key)
      _ -> 
        unique_constraint(model, key, params)
    end
  end

  defp unique_constraint(model, key, params) when is_atom(key) do
    Changeset.unique_constraint(model, key, params)
  end
  defp unique_constraint(model, [key | _tail] = keys, params) when is_list(keys) do
    Changeset.unique_constraint(model, key, params)
  end

  defp validate_uniqueness_of(model, key) when is_atom(key) do
    case model.changes[key] do
      nil   -> {:error, model, nil}
      value ->
        {:ok, model, value}
    end
  end
  defp validate_uniqueness_of(_, []), do: []
  defp validate_uniqueness_of(model, [key | tail] = keys) when is_list(keys) do
    case validate_uniqueness_of(model, key) do
      {_, _, nil} -> {:error, model, nil}
      {_, _, value} ->
        {:ok, model, List.flatten([value | values_to_validate(model, tail)])}
    end
  end

  defp values_to_validate(_model, []), do: []
  defp values_to_validate(model, [key | tail] = keys) when is_list(keys) do
    value =
      case validate_uniqueness_of(model, key) do
        {_, _, nil} -> []
        {_, _, val} -> val
      end
    [value | values_to_validate(model, tail)]
  end

  defp try_to_find_value({:error, model, nil}, _key), do: model
  defp try_to_find_value({:ok, model, value}, key) when is_atom(key) do
    case Repo.get_by(model.model.__struct__, Keyword.new([{key, value}])) do
      nil -> model
      _   -> Changeset.add_error(model, key, "ist bereits vergeben")
    end
  end
  defp try_to_find_value({:ok, model, values}, keys) when is_list(keys) do
    if Enum.count(keys) == Enum.count(values) do
      find_value(model, keys, values)
    else
      model
    end
  end

  defp find_value(model, keys, values) do
    conditions = Enum.zip(keys, values) |> Enum.into(%{})
    case Repo.get_by(model.model.__struct__, conditions) do
      nil -> model
      _   -> Changeset.add_error(model, get_model_name(model), "existiert bereits")
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
