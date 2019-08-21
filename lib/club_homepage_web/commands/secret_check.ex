defmodule ClubHomepageWeb.SecretCheck do
  @moduledoc """
  Holds secret logic to validate and delete old secrets.
  """

  import Ecto.Query, only: [from: 2]
  import Ecto.Changeset, only: [add_error: 3]

  alias ClubHomepage.Repo
  alias ClubHomepage.Secret

  @doc """
  Checks a given secret is valid. When not, it adds an error to the given changeset.
  """
  @spec run(Changeset.t, String.t) :: Changeset.t
  def run(changeset, secret_key) do
    changeset 
    |> empty(secret_key)
    |> exists(secret_key)
    |> expired
  end

  @doc """
  Deletes a given secret.
  """
  @spec delete(String.t) :: {integer, nil | [term]} | no_return
  def delete(secret_key) do
    from(s in Secret, where: s.key == ^secret_key) |> Repo.delete_all
  end

  defp empty(changeset, nil), do: {:error, add_error(changeset, :secret, "can't be blank")}
  defp empty(changeset, _secret_key) do 
    {:ok, changeset}
  end

  defp exists({:error, changeset}, _secret_key), do: {:error, changeset, nil}
  defp exists({:ok, changeset}, secret_key) do
    case Repo.one(from s in Secret, where: s.key == ^secret_key, select: s) do
      nil -> {:error, add_error(changeset, :secret, "not found"), nil}
      secret -> {:ok, changeset, secret}
    end
  end

  defp expired({:error, changeset, nil}), do: changeset
  defp expired({:ok, changeset, secret}) do 
    case Timex.compare(Timex.local, secret.expires_at) do
      1 -> 
        delete(secret.key)
        add_error(changeset, :secret, "has expired")
      _ -> changeset
    end
  end
end
