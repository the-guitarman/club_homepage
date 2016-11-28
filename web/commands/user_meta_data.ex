defmodule ClubHomepage.UserMetaData do
  @moduledoc """
  """

  import Ecto.Query, only: [from: 2]

  alias ClubHomepage.User
  alias ClubHomepage.TeamChatMessage
  alias ClubHomepage.Repo

  @doc """
  """

  # - user.meta_data[:last_read_team_chat_message_timestamps] = %{team_id => timestamp}
  # - show number of unread messages
  #   - team_id + timestamp => unread_team_chat_messages_number
  # - show unread messages:
  #   - last_read_id/timestamp
  #   - team_id + timestamp => unread_team_chat_messages

  def save_last_read_team_chat_message_id(team_id, chat_message_id, user) do
    user_meta_data =
      case user.meta_data do
        nil -> %{}
        meta_data -> meta_data
      end

    last_read_team_chat_message_ids =
      case user_meta_data[:last_read_team_chat_message_ids] do
        nil -> %{Integer.to_string(team_id) => chat_message_id}
        last_read_team_chat_message_ids -> Map.put(last_read_team_chat_message_ids, Integer.to_string(team_id), chat_message_id)
      end

    user_meta_data = Map.put(user_meta_data, :last_read_team_chat_message_ids, last_read_team_chat_message_ids)
    changeset = User.changeset(user, %{"meta_data" => user_meta_data})
    Repo.update(changeset)
  end

  def unread_team_chat_messages(team_id, user) do
    team_id
    |> unread_team_chat_messages_query(user)
    |> Repo.all
  end

  def unread_team_chat_messages_number(team_id, user) do
    team_id
    |> unread_team_chat_messages_query(user)
    |> Repo.aggregate(:count, :id)
  end

  def last_read_team_chat_message_id(team_id, user) do
    case user.meta_data[:last_read_team_chat_message_ids] do
      nil -> nil
      timestamps -> timestamps[team_id]
    end
  end

  defp unread_team_chat_messages_query(team_id, user) do
    query = from(tcm in TeamChatMessage, where: tcm.team_id == ^team_id)
    #IO.inspect Ecto.Adapters.SQL.to_sql(:all, Repo, query)
    case last_read_team_chat_message_id(team_id, user.meta_data) do
      nil -> query
      chat_message_id -> from(tcm in query, where: tcm.id > ^chat_message_id)
    end
  end
end
