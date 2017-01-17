defmodule ClubHomepage.Extension.CommonMatch do
  alias ClubHomepage.Repo
  alias ClubHomepage.User

  def failure_reasons do
    Application.get_env(:club_homepage, :match)[:failure_reasons]
  end

  def internal_user_name(%User{} = user) do
    user_name(user)
  end
  def internal_user_name(%{name: name, nickname: nickname}) do
    user_name(%{name: name, nickname: nickname})
  end
  def internal_user_name(id) when is_integer(id) do
    internal_user_name(Repo.get!(User, id))
  end

  defp user_name(%{name: name, nickname: nickname}) do
    case nickname do
      nil -> name
      nick_name -> nick_name
    end
  end
end
