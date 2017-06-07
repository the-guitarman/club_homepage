defmodule ClubHomepage.TeamChatBadgeChannel do
  use ClubHomepage.Web, :channel

  alias ClubHomepage.UserMetaData

  def join("team-chat-badges:" <> team_id, _payload, socket) do
    team_id = String.to_integer(team_id)
    current_user = socket.assigns.current_user

    response = %{
      "unread_team_chat_messages_number" => UserMetaData.unread_team_chat_messages_number(team_id, current_user),
      "current_user_id" => current_user.id
    }
 
    {:ok, response, assign(socket, :team_id, team_id)}
  end

  def handle_out(event, payload, socket) do
    push socket, event, payload
    {:noreply, socket}
  end

  # defp get_team_id_from_socket_assigns(socket) do
  #   value_to_integer(socket.assigns.team_id)
  # end

  # defp value_to_integer(value) when is_integer(value) do
  #   value
  # end
  # defp value_to_integer(value) when is_bitstring(value) do
  #   String.to_integer(value)
  # end
end
