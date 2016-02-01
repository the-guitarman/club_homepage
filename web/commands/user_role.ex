defmodule ClubHomepage.UserRole do
  alias Ecto.Changeset

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

  def check_roles(%{model: model, changes: changes} = changeset) do
    changeset
    |> check_current_roles(model)
    |> check_changes(changes)
  end

  defp check_current_roles(changeset, model) do
    case model.roles do
      nil -> Changeset.put_change(changeset, :roles, "member")
      _   -> changeset
    end
  end

  defp check_changes(changeset, changes) do
    case changes[:roles] do
      nil -> changeset
      _   -> Changeset.put_change(changeset, :roles, clean_up_roles(changes.roles))
    end
  end

  defp clean_up_roles(roles) do
    roles
    |> String.split
    |> Enum.map(fn(s) -> String.strip(s) end)
    |> Enum.filter(fn(s) -> Enum.member?(@roles, s) end)
    |> Enum.uniq
    |> ensure_member_role_exists
    |> Enum.join(" ")
  end

  defp ensure_member_role_exists(roles) do
    case Enum.member?(roles, "member") do
      false -> ["member" | roles]
      _     -> roles
    end
  end
end
