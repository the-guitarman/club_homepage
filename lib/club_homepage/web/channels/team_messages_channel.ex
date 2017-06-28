defmodule ClubHomepage.Web.TeamMessagesChannel do
  use ClubHomepage.Web, :channel

  def join("team_messages:" <> team_id, _params, socket) do
    {:ok, assign(socket, :team_id, team_id)}
  end

  def handle_in("new:event", msg, socket) do
    #broadcast!(socket, "new:event", %{user: msg["user"], body: msg["body"]})
    broadcast!(socket, "new:event", msg)
    {:noreply, socket}
  end
end
