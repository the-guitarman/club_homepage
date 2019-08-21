defmodule ClubHomepageWeb.StandardTeamPlayersChannel do
  use ClubHomepageWeb, :channel

  alias ClubHomepage.Repo
  alias ClubHomepage.StandardTeamPlayer

  def join("standard-team-players:" <> team_id, _payload, socket) do
    team_id = String.to_integer(team_id)
    {:ok, assign(socket, :team_id, team_id)}
  end

  def handle_in("player:add_or_update", %{"user_id" => user_id, "standard_shirt_number" => standard_shirt_number}, socket) do
    {state, payload} = 
      add_or_update_standard_team_player(socket.assigns.team_id, user_id, standard_shirt_number)
      |> get_payload(socket.assigns.team_id, user_id, standard_shirt_number)
      |> send_broadcast(socket)

    get_reply(socket, state, payload)
  end
  def handle_in("player:remove", %{"user_id" => user_id, "standard_shirt_number" => _standard_shirt_number}, socket) do
    remove_player(socket.assigns.team_id, user_id)
    result =  %{team_id: socket.assigns.team_id, user_id: user_id, standard_shirt_number: ""}
    broadcast socket, "player:removed", result
    get_reply(socket, :ok, result)
  end

  defp add_or_update_standard_team_player(team_id, user_id, standard_shirt_number) do
    case find_player(team_id, user_id) do
      nil -> add_player(team_id, user_id, standard_shirt_number)
      player -> update_player(player, standard_shirt_number)
    end
  end

  defp get_payload({:ok, standard_team_player}, team_id, user_id, _standard_shirt_number) do
    payload = base_payload(team_id, user_id, standard_team_player.standard_shirt_number)
    {:ok, payload}
  end
  defp get_payload({:error, changeset}, team_id, user_id, standard_shirt_number) do
    errors =
      Enum.map(changeset.errors, fn({field, {error, _}}) -> {field, error} end)
      |> Enum.into(%{})

    payload =
      base_payload(team_id, user_id, standard_shirt_number)
      |> Map.put(:errors, errors)
    {:error, payload}
  end

  defp base_payload(team_id, user_id, standard_shirt_number) do
    %{:team_id => team_id, :user_id => user_id, standard_shirt_number: standard_shirt_number}
  end

  defp get_reply(socket, state, payload) do
    {:reply, {state, payload}, socket}
  end

  defp send_broadcast({:ok, payload}, socket) do
    broadcast socket, "player:added_or_updated", payload
    {:ok, payload}
  end
  defp send_broadcast(reply, _socket) do
    reply
  end

  defp find_player(team_id, user_id) do
    Repo.get_by(StandardTeamPlayer, team_id: team_id, user_id: user_id)
  end

  defp add_player(team_id, user_id, standard_shirt_number) do
    changeset = StandardTeamPlayer.changeset(%StandardTeamPlayer{}, %{team_id: team_id, user_id: user_id, standard_shirt_number: standard_shirt_number})
    Repo.insert(changeset)
  end

  defp update_player(%StandardTeamPlayer{} = player, standard_shirt_number) do
    changeset = StandardTeamPlayer.changeset(player, %{standard_shirt_number: standard_shirt_number})
    Repo.update(changeset)
  end

  defp remove_player(team_id, user_id) do
    Repo.delete_all(from(stp in StandardTeamPlayer, where: [team_id: ^team_id, user_id: ^user_id]))
  end
end
