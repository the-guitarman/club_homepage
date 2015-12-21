defmodule ClubHomepage.UserRole do

  # member  - simple a member of the club, a rigistered user
  # player  - an active sports men/woman
  # trainer - responsible for a team
  # editor  - reporter of game/match results, author of news
  # administrator - has all rights
  @roles ~w(administrator member player trainer editor)

  def has_role?(user, role) do
    user.roles
    |> split
    |> include?(role)
    |> valid?(role)
  end

  defp split(roles) do
    String.split(roles)
  end

  defp include?(roles, role) do
    Enum.member?(roles, role)
  end

  defp valid?(false, _role), do: false
  defp valid?(true, role) do
    Enum.member?(@roles, role)
  end
end