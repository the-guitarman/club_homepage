defmodule ClubHomepage.Web.UserMetaData do
  @moduledoc """
  Module provides helper methods for serialized user meta_data field.
  """

  import Ecto.Query, only: [from: 2]

  alias ClubHomepage.User
  alias ClubHomepage.TeamChatMessage
  alias ClubHomepage.Repo

  @doc """

  """
  @spec save_last_read_team_chat_message_id(Integer.t, Integer.t, User) :: {ok, User} | {:error, Ecto.Changeset.t}
  def save_last_read_team_chat_message_id(team_id, chat_message_id, user) do
    meta_data = user_meta_data(user)

    last_read_team_chat_message_ids =
      case meta_data["last_read_team_chat_message_ids"] do
        nil -> %{Integer.to_string(team_id) => chat_message_id}
        last_read_team_chat_message_ids -> Map.put(last_read_team_chat_message_ids, Integer.to_string(team_id), chat_message_id)
      end

    meta_data = Map.put(meta_data, "last_read_team_chat_message_ids", last_read_team_chat_message_ids)
    changeset = User.changeset(user, %{"meta_data" => meta_data})
    Repo.update(changeset)
  end

  @doc """
  """
  @spec unread_team_chat_messages(Integer.t, User) :: List.t
  def unread_team_chat_messages(team_id, user) do
    team_id
    |> unread_team_chat_messages_query(user)
    |> Repo.all
  end

  @doc """
  """
  @spec unread_team_chat_messages_number(Integer.t, User) :: Integer.t
  def unread_team_chat_messages_number(team_id, user) do
    team_id
    |> unread_team_chat_messages_query(user)
    |> Repo.aggregate(:count, :id)
  end

  @doc """
  """
  @spec last_read_team_chat_message_id(Integer.t, User) :: Integer.t | nil
  def last_read_team_chat_message_id(team_id, user) do
    case user_meta_data(user)["last_read_team_chat_message_ids"] do
      nil -> nil
      timestamps -> timestamps[Integer.to_string(team_id)]
    end
  end

  defp unread_team_chat_messages_query(team_id, user) do
    query = from(tcm in TeamChatMessage, where: tcm.team_id == ^team_id)
    #IO.inspect Ecto.Adapters.SQL.to_sql(:all, Repo, query)
    case last_read_team_chat_message_id(team_id, user) do
      nil -> query
      chat_message_id -> from(tcm in query, where: tcm.id > ^chat_message_id)
    end
  end

  defp user_meta_data(user) do
    case user.meta_data do
      nil -> %{}
      meta_data -> meta_data
    end
  end
end
