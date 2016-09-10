defmodule ClubHomepage.TeamChatChannel do
  use ClubHomepage.Web, :channel

  alias ClubHomepage.TeamChatMessage
  alias ClubHomepage.Repo

  def join("team-chats:" <> team_id, _payload, socket) do
    chat_messages = get_latest_chat_messages(team_id)
    response = %{chat_messages: chat_messages}

    {:ok, response, assign(socket, :team_id, team_id)}
  end

  def handle_in("message:add", payload, socket) do
    team_id = String.to_integer(socket.assigns.team_id)
    user = socket.assigns.current_user

    payload = Map.put(payload, "team_id", team_id)
    payload = Map.put(payload, "user_id", user.id)
    changeset = TeamChatMessage.changeset(%TeamChatMessage{}, payload)

    case Repo.insert(changeset) do
      {:ok, team_chat_message} ->
        team_chat_message = Repo.preload(team_chat_message, :user)
        broadcast socket, "message:added", broadcast_message(team_chat_message)
        {:reply, :ok, socket}
      {:error, changeset} ->
        {:reply, {:error, %{errors: changeset}}, socket}
    end
  end

  defp get_latest_chat_messages(team_id) do
    Repo.all(from(tcm in TeamChatMessage, preload: [:user], where: tcm.team_id == ^team_id, limit: 10, order_by: [desc: tcm.inserted_at]))
    |> Enum.reverse
    |> Enum.map(fn(team_chat_message) -> broadcast_message(team_chat_message) end)
  end

  defp broadcast_message(team_chat_message) do
    %{"user_name" => internal_user_name(team_chat_message.user), "at" => team_chat_message.inserted_at, "message" => team_chat_message.message}
  end
end
