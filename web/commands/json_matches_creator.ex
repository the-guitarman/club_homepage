defmodule JsonMatchesCreator do
  @moduledoc """
  Creates matches from a json.
  """

  alias ClubHomepage.Match

  @doc """
  Creates matches from a valid changeset returned by MatchesJsonValidator.
  """
  @spec run(Ecto.Changeset) :: Integer
  def run(changeset) do
    
  end
end
