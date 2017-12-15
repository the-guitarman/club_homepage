defmodule ClubHomepage.Web.StandardTeamPlayersChannel do
  use ClubHomepage.Web, :channel

  alias ClubHomepage.Repo
  alias ClubHomepage.StandardTeamPlayer

  def join("standard-team-players:" <> team_id, _payload, socket) do
    team_id = String.to_integer(team_id)
    {:ok, assign(socket, :team_id, team_id)}
  end

  def handle_in("player:add", %{"user_id" => user_id}, socket) do
    state = add_player(socket.assigns.team_id, user_id)
    result =  %{:team_id => socket.assigns.team_id, :user_id => user_id}
    if state == :ok do
      broadcast socket, "player:added", result
    end
    get_reply(socket, state, result)
  end

  def handle_in("player:remove", %{"user_id" => user_id}, socket) do
    remove_player(socket.assigns.team_id, user_id)
    result =  %{team_id: socket.assigns.team_id, user_id: user_id}
    broadcast socket, "player:removed", result
    get_reply(socket, :ok, result)
  end

  defp get_reply(socket, state, payload) do
    {:reply, {state, payload}, socket}
  end

  defp add_player(team_id, user_id) do
    changeset = StandardTeamPlayer.changeset(%StandardTeamPlayer{}, %{team_id: team_id, user_id: user_id})
    case Repo.insert(changeset) do
      {:ok, _standard_team_player} -> :ok
      {:error, _changeset} -> :error
    end
  end

  defp remove_player(team_id, user_id) do
    Repo.delete_all(from(stp in StandardTeamPlayer, where: [team_id: ^team_id, user_id: ^user_id]))
  end
end
