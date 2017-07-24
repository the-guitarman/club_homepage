defmodule ClubHomepage.Web.UserView do
  use ClubHomepage.Web, :view

  def user_role_checked(user, role) do
    case has_role?(user, [role]) do
      true  -> "checked=\"checked\""
      _     -> ""
    end
  end

  def user_role_humanized(role) do
    role
    |> String.replace("-", " ")
    |> String.split(" ")
    |> Enum.map(fn(s) -> String.capitalize(s) end)
    |> Enum.join(" ")
  end
end
