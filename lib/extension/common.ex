defmodule ClubHomepage.Extension.Common do
  alias ClubHomepage.Repo
  alias ClubHomepage.User

  def project_host(conn) do
    case conn.port do
      80 -> conn.host
      port -> "#{conn.host}:#{port}"
    end
  end

  def failure_reasons do
    Application.get_env(:club_homepage, :match)[:failure_reasons]
  end

  def internal_user_name(%User{} = user) do
    nickname_or_name(user)
  end
  def internal_user_name(%{name: name, nickname: nickname}) do
    nickname_or_name(%{name: name, nickname: nickname})
  end
  def internal_user_name(id) when is_integer(id) do
    id
    |> get_user_by_id
    |> internal_user_name
  end

  defp nickname_or_name(%{name: name, nickname: nickname}) do
    case nickname do
      nil -> name
      nick_name -> nick_name
    end
  end

  def user_name(%User{} = user) do
    user.name
  end
  def user_name(id) when is_integer(id) do
    id
    |> get_user_by_id
    |> user_name
  end

  defp get_user_by_id(id) do
    Repo.get!(User, id)
  end
end
