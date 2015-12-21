defmodule ClubHomepage.ModelValidator do 
  @moduledoc """
      
  """

  alias ClubHomepage.Repo
  alias Ecto.Changeset

  @doc """

  """
  @spec validate_uniqueness( Ecto.Changeset, Atom, Keyword ) :: Ecto.Changeset
  def validate_uniqueness(model, key, params) do
    case Application.get_env(:club_homepage, Repo)[:adapter] do
      Sqlite.Ecto -> 
        model
        |> validate_uniqueness_of(key)
        |> try_to_find_value(key)
      _ -> 
        Changeset.unique_constraint(model, key, params)
    end
  end

  defp validate_uniqueness_of(model, key) do
    case model.changes[key] do
      nil   -> {:error, model, nil}
      value -> {:ok, model, value}
    end
  end

  defp try_to_find_value({:error, model, nil}, _key), do: model
  defp try_to_find_value({:ok, model, value}, key) do
    case Repo.get_by(model.model.__struct__, Keyword.new([{key, value}])) do
      nil -> model
      _   -> Changeset.add_error(model, key, "ist bereits vergeben")
    end
  end
end