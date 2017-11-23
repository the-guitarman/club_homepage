defmodule ClubHomepage.Web.StandardTeamPlayersChannel do
  use ClubHomepage.Web, :channel

  alias ClubHomepage.Repo
  alias ClubHomepage.StandardTeamPlayer
  alias ClubHomepage.User

  def join("standard-team-players:" <> team_id, _payload, socket) do
    team_id = String.to_integer(team_id)
    {:ok, assign(socket, :team_id, team_id)}
  end

  def handle_in("player:add", %{"user_id" => user_id}, socket) do
    result =  %{team_id: socket.assigns.team_id, user_id: user_id}
    broadcast socket, "player:added", result
    get_reply(socket, result)
  end

  def handle_in("player:remove", %{"user_id" => user_id}, socket) do
    result =  %{team_id: socket.assigns.team_id, user_id: user_id}
    broadcast socket, "player:removed", result
    get_reply(socket, result)
  end

  defp get_reply(socket, payload) do
    {:reply, {:ok, payload}, socket}
  end
end
