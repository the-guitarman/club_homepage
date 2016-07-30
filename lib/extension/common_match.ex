defmodule ClubHomepage.Extension.CommonMatch do
  alias ClubHomepage.Repo
  alias ClubHomepage.User

  def failure_reasons do
    Application.get_env(:club_homepage, :match)[:failure_reasons]
  end

  def internal_user_name(%User{} = user) do
    case user.nickname do
      nil -> user.name
      nickname -> nickname
    end
  end
  def internal_user_name(id) when is_integer(id) do
    internal_user_name(Repo.get!(User, id))
  end
end
