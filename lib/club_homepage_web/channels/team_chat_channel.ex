defmodule ClubHomepage.Web.TeamChatChannel do
  use ClubHomepage.Web, :channel

  alias ClubHomepage.TeamChatMessage
  alias ClubHomepage.Repo
  alias ClubHomepage.Web.UserMetaData

  @limit 10

  def join("team-chats:" <> team_id, _payload, socket) do
    team_id = String.to_integer(team_id)
    current_user = socket.assigns.current_user

    response =
      team_id
      |> get_last_read_team_chat_message_id(current_user)
      |> get_unread_team_chat_messages_number(current_user)
      |> get_latest_chat_messages_query
      |> get_team_chat_messages_response
      |> create_response(current_user)
      |> save_last_read_team_chat_message_id(team_id, current_user)

    {:ok, response, assign(socket, :team_id, team_id)}
  end

  def handle_in("message:add", payload, socket) do
    team_id = get_team_id_from_socket_assigns(socket)
    current_user = socket.assigns.current_user

    payload = Map.put(payload, "team_id", team_id)
    payload = Map.put(payload, "user_id", current_user.id)
    changeset = TeamChatMessage.changeset(%TeamChatMessage{}, payload)

    case Repo.insert(changeset) do
      {:ok, team_chat_message} ->
        team_chat_message = Repo.preload(team_chat_message, :user)

        response =
          team_id
          |> get_last_read_team_chat_message_id(current_user)
          |> get_unread_team_chat_messages_number(current_user)
          |> get_team_chat_message_response(team_chat_message)
          |> create_response(current_user)

        save_last_read_team_chat_message_id(team_chat_message.id, team_id, current_user)

        broadcast socket, "message:added", response
        # broadcast(topic_name, event_name, payload_map)
        ClubHomepage.Web.Endpoint.broadcast("team-chat-badges:#{team_id}", "message:added", response)
        {:reply, :ok, socket}
      {:error, changeset} ->
        {:reply, {:error, %{errors: changeset}}, socket}
    end
  end

  def handle_in("message:seen", payload, socket) do
    team_id = get_team_id_from_socket_assigns(socket)
    current_user = socket.assigns.current_user
    UserMetaData.save_last_read_team_chat_message_id(team_id, payload["message_id"], current_user)
    # {:noreply, socket}
    {:reply, :ok, socket}
  end

  def handle_in("message:show-older", payload, socket) do
    team_id = get_team_id_from_socket_assigns(socket)
    current_user = socket.assigns.current_user

    id_lower_than = payload["id_lower_than"]

    {query, _, _, _} = get_latest_chat_messages_query({team_id, nil, nil})
    query = from(tcm in query, where: tcm.id < ^id_lower_than)
    response =
      {query, team_id, nil, nil}
      |> get_team_chat_messages_response
      |> create_response(current_user)

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
    maximum_id = Repo.one(from(tcm in TeamChatMessage, select: max(tcm.id)))

    cond do
      maximum_id == nil -> get_latest_chat_messages_query({team_id, nil, nil})
      maximum_id > last_read_team_chat_message_id ->
        query = from(tcm in TeamChatMessage, preload: [:user], where: tcm.team_id == ^team_id, where: tcm.id > ^last_read_team_chat_message_id, order_by: [desc: tcm.id])
        {query, team_id, last_read_team_chat_message_id, unread_team_chat_messages_number}
      true -> get_latest_chat_messages_query({team_id, nil, nil})
    end
  end

  defp get_team_chat_message_response({team_id, last_read_team_chat_message_id, unread_team_chat_messages_number}, team_chat_message) do
    response = %{chat_message: broadcast_message(team_chat_message)}
    {response, team_id, last_read_team_chat_message_id, unread_team_chat_messages_number}
  end

  defp get_team_chat_messages_response({query, team_id, last_read_team_chat_message_id, unread_team_chat_messages_number}) do
    chat_messages = create_response_objects(query)
    chat_message_with_minimum_id = chat_message_with_minimum_id(chat_messages)
    response = %{
      chat_messages: chat_messages,
      older_chat_messages_available: older_chat_messages_available?(team_id, chat_message_with_minimum_id["id"])
    }
    {response, team_id, last_read_team_chat_message_id, unread_team_chat_messages_number}
  end

  defp save_last_read_team_chat_message_id(chat_message_id, team_id, user) when is_integer(chat_message_id) do
    UserMetaData.save_last_read_team_chat_message_id(team_id, chat_message_id, user)
  end
  defp save_last_read_team_chat_message_id(response, team_id, user) when is_map(response) do
    case response.chat_messages do
      [] -> nil
      _ -> 
        chat_message_map = Enum.max_by(response.chat_messages, fn(cm) -> cm["id"] end)
        UserMetaData.save_last_read_team_chat_message_id(team_id, chat_message_map["id"], user)
    end
    response
  end

  defp get_team_id_from_socket_assigns(socket) do
    value_to_integer(socket.assigns.team_id)
  end

  defp value_to_integer(value) when is_integer(value) do
    value
  end
  defp value_to_integer(value) when is_bitstring(value) do
    String.to_integer(value)
  end

  defp older_chat_messages_available?(_team_id, nil), do: false
  defp older_chat_messages_available?(team_id, chat_message_id) do
    Repo.one(from(tcm in TeamChatMessage, select: count(tcm.id), where: tcm.team_id == ^team_id, where: tcm.id < ^chat_message_id)) > 0
  end

  defp create_response({response, _team_id, last_read_team_chat_message_id, unread_team_chat_messages_number}, current_user) do
    response
    |> Map.put(:last_read_team_chat_message_id, last_read_team_chat_message_id)
    |> Map.put(:unread_team_chat_messages_number, unread_team_chat_messages_number)
    |> Map.put(:current_user_id, current_user.id)
  end

  defp create_response_objects(query) do
    query
    |> Repo.all
    |> Enum.reverse
    |> Enum.map(fn(team_chat_message) -> broadcast_message(team_chat_message) end)
  end

  defp chat_message_with_minimum_id([]), do: %{"id" => nil}
  defp chat_message_with_minimum_id(chat_messages) do
    Enum.min_by(chat_messages, fn(chat_message) -> chat_message["id"] end)
  end

  defp broadcast_message(team_chat_message) do
    %{"id" => team_chat_message.id, "user_id" => team_chat_message.user.id, "user_name" => internal_user_name(team_chat_message.user), "at" => to_iso8601(team_chat_message.inserted_at), "message" => team_chat_message.message}
  end

  defp to_iso8601(datetime) do
    {:ok, iso8601} = datetime |> Timex.format("{ISO:Extended}")
    iso8601
  end
end
