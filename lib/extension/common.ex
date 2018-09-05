defmodule ClubHomepage.Extension.Common do
  @moduledoc """
  Provides some global functions.
  """

  alias ClubHomepage.Repo
  alias ClubHomepage.User

  def project_host(conn) do
    case conn.port do
      80 -> conn.host
      port -> "#{conn.host}:#{port}"
    end
  end

  @doc """
  Returns a list with all configured match failure reasons from `config/config.exs`.

  ## Example usage
  iex> ClubHomepage.Extension.Common.failure_reasons()
  ["aborted", "failed", "canceled", "team_missed"]
  """
  @spec failure_reasons() :: List
  def failure_reasons do
    Application.get_env(:club_homepage, :match)[:failure_reasons]
  end

  @doc """
  Returns the nickname of a user, if defined. Otherwise it returns the name.

  ## Example usage
  iex> alias ClubHomepage.User
  iex> ClubHomepage.Extension.Common.internal_user_name(%User{name: "name", nickname: "nick"})
  "nick"
  iex> ClubHomepage.Extension.Common.internal_user_name(%User{name: "name", nickname: nil})
  "name"
  iex> ClubHomepage.Extension.Common.internal_user_name(%User{name: "name"})
  "name"
  """
  @spec internal_user_name(User) :: String
  @spec internal_user_name(Integer) :: String
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

  @doc """
  Returns the name of a given user.

  ## Example usage
  iex> alias ClubHomepage.User
  iex> ClubHomepage.Extension.Common.user_name(%User{name: "name"})
  "name"
  """
  @spec user_name(User) :: String
  @spec user_name(Integer) :: String
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

  @doc """
  Returns values from `config` section in `config/club_hompage.exs`.

  ## Example usage
  iex> ClubHomepage.Extension.Common.get_config(:show_match_timeline)
  false
  """
  @spec get_config(Atom) :: Boolean
  def get_config(key) do
    Application.get_env(:club_homepage, :config)[key]
  end
end
