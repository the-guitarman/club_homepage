defmodule ClubHomepage.TeamChatChannel do
  use ClubHomepage.Web, :channel

  alias ClubHomepage.TeamChatMessage
  alias ClubHomepage.Repo
  alias ClubHomepage.UserMetaData

  @limit 10

  def join("team-chats:" <> team_id, _payload, socket) do
    user = socket.assigns.current_user

    response =
      team_id
      |> get_last_read_team_chat_message_id(user)
      |> get_unread_team_chat_messages_number(user)
      |> get_latest_chat_messages_query
      |> create_response

    {:ok, response, assign(socket, :team_id, team_id)}
  end

  def handle_in("message:add", payload, socket) do
    team_id = get_team_id_from_socket_assigns(socket)
    user = socket.assigns.current_user

    payload = Map.put(payload, "team_id", team_id)
    payload = Map.put(payload, "user_id", user.id)
    changeset = TeamChatMessage.changeset(%TeamChatMessage{}, payload)

    case Repo.insert(changeset) do
      {:ok, team_chat_message} ->
        #older_chat_messages_available?(team_id)
        team_chat_message = Repo.preload(team_chat_message, :user)
        broadcast socket, "message:added", broadcast_message(team_chat_message)
        {:reply, :ok, socket}
      {:error, changeset} ->
        {:reply, {:error, %{errors: changeset}}, socket}
    end
  end
  def handle_in("message:show-older", payload, socket) do
    team_id = get_team_id_from_socket_assigns(socket)
    #user = socket.assigns.current_user

    id_lower_than = payload["id_lower_than"]

    {query, _, _, _} = get_latest_chat_messages_query({team_id, nil, nil})
    query = from(tcm in query, where: tcm.id < ^id_lower_than)
    response = create_response({query, team_id, nil, nil})

    push socket, "message:show-older", response

    {:noreply, socket}
    # {:reply, {:ok, response}, socket}
    # {:reply, :ok, socket}
  end

  defp get_last_read_team_chat_message_id(team_id, user) do
    {team_id, UserMetaData.last_read_team_chat_message_id(team_id, user)}
  end

  defp get_unread_team_chat_messages_number({team_id, last_read_team_chat_message_id}, user) do
    {team_id, last_read_team_chat_message_id, UserMetaData.unread_team_chat_messages_number(team_id, user)}
  end

  defp get_latest_chat_messages_query({team_id, nil, _}) do
    query = from(tcm in TeamChatMessage, preload: [:user], where: tcm.team_id == ^team_id, limit: @limit, order_by: [desc: tcm.id])
    {query, team_id, nil, nil}
  end
  defp get_latest_chat_messages_query({team_id, last_read_team_chat_message_id, unread_team_chat_messages_number}) do
    query = from(tcm in TeamChatMessage, preload: [:user], where: tcm.team_id == ^team_id, where: tcm.id > ^last_read_team_chat_message_id, order_by: [desc: tcm.id])
    {query, team_id, last_read_team_chat_message_id, unread_team_chat_messages_number}
  end

  defp get_team_id_from_socket_assigns(socket) do
    String.to_integer(socket.assigns.team_id)
  end

  defp older_chat_messages_available?(_team_id, nil), do: false
  defp older_chat_messages_available?(team_id, chat_message_id) do
    Repo.one(from(tcm in TeamChatMessage, select: count(tcm.id), where: tcm.team_id == ^team_id, where: tcm.id < ^chat_message_id)) > 0
  end

  defp create_response({query, team_id, last_read_team_chat_message_id, unread_team_chat_messages_number}) do
    chat_messages = create_response_objects(query)
    chat_message_with_minimum_id = 
      case chat_messages do
        [] -> %{"id" => nil}
        _ -> Enum.min_by(chat_messages, fn(chat_message) -> chat_message["id"] end)
      end

    %{
      chat_messages: chat_messages,
      last_read_team_chat_message_id: last_read_team_chat_message_id,
      unread_team_chat_messages_number: unread_team_chat_messages_number,
      older_chat_messages_available: older_chat_messages_available?(team_id, chat_message_with_minimum_id["id"])
    }
  end

  defp create_response_objects(query) do
    query
    |> Repo.all
    |> Enum.reverse
    |> Enum.map(fn(team_chat_message) -> broadcast_message(team_chat_message) end)
  end

  defp broadcast_message(team_chat_message) do
    %{"id" => team_chat_message.id, "user_id" => team_chat_message.user.id, "user_name" => internal_user_name(team_chat_message.user), "at" => team_chat_message.inserted_at, "message" => team_chat_message.message}
  end
end
