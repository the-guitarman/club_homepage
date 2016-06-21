defmodule ClubHomepage.MatchTimelineChannel do
  use ClubHomepage.Web, :channel

  alias ClubHomepage.Match
  alias ClubHomepage.Repo

  def join("match-timelines:" <> match_id, _params, socket) do
    #:timer.send_interval(5_000, :ping)

    {_, _, match_events} = 
      {socket, match_id}
      |> get_match
      |> get_match_events

    response = %{match_events: match_events}

    {:ok, response, assign(socket, :match_id, match_id)}
  end

  # # For now, know that handle_in receives direct channel events, handle_out intercepts broadcast events, and handle_info receives OTP messages.
  # def handle_info(:ping, socket) do
  #   count = socket.assigns[:count] || 1
  #   push socket, "ping", %{count: count}

  #   {:noreply, assign(socket, :count, count + 1)}
  # end

  def handle_in("match-event:add", match_event, socket) do
    socket
    |> get_match_id
    |> get_match
    |> get_match_events
    |> add_match_event(match_event)
    |> save_match_events
    |> send_broadcast("match-event:add")
    |> send_response
  end
  def handle_in("match-event:remove", match_event_index, socket) do
    socket
    |> get_match_id
    |> get_match
    |> get_match_events
    |> remove_match_event(match_event_index)
    |> save_match_events
    |> send_broadcast("match-event:remove")
    |> send_response
  end
  def handle_in("match-event:final-whistle", match_score, socket) do
    socket
    |> get_match_id
    |> get_match
    |> save_match_score(match_score)
    |> send_response
  end

  # # This is invoked every time a notification is being broadcast
  # # to the client. The default implementation is just to push it
  # # downstream but one could filter or change the event.
  # # def handle_out(event, payload, socket) do
  # #   push socket, event, payload
  # #   {:noreply, socket}
  # # end

  # def terminate(_reason, _socket) do
  #   :ok
  # end

  # def leave(_reason, socket) do
  #   {:ok, socket}
  # end

  defp get_match_id(socket) do
    {socket, socket.assigns.match_id}
  end

  defp get_match({socket, match_id}) do
    {socket, Repo.get!(Match, match_id)}
  end

  defp get_match_events({socket, match}) do
    case match.match_events do
      nil -> {socket, match, []}
      match_events -> {socket, match, parse_match_events(match_events)}
    end
  end

  defp add_match_event({socket, match, match_events}, match_event) do
    new_match_events = Enum.reverse([match_event | Enum.reverse(match_events)])
    {socket, match, new_match_events, match_event}
  end

  defp remove_match_event({socket, match, match_events}, match_event_index) do
    [_last_match_event | new_match_events] = Enum.reverse(match_events)
    {socket, match, Enum.reverse(new_match_events), match_event_index}
  end

  defp save_match_events({socket, match, match_events_list, broadcast_message}) do
    result = save_match(match, %{match_events: stringify_match_events(match_events_list)})
    {socket, result, broadcast_message}
  end

  defp save_match_score({socket, match}, match_score) do
    {socket, save_match(match, match_score_attributes(match, match_score))}
  end

  defp save_match(match, attributes) do
    match
    |> Match.changeset(attributes)
    |> Repo.update
  end

  defp send_broadcast({socket, result, broadcast_message}, event_name) do
    case result do
      {:ok, _} -> broadcast!(socket, event_name, broadcast_message)
    end
    {socket, result}
  end

  defp send_response({socket, result}) do
    case result do
      {:ok, _} ->
        {:reply, :ok, socket}
      {:error, changeset} ->
        {:reply, {:error, %{errors: changeset}}, socket}
    end
    # {:noreply, socket}
  end

  defp parse_match_events(match_events_string) do
    {:ok, match_events_list} = JSON.decode(match_events_string)
    match_events_list
  end

  defp stringify_match_events(match_events_list) do
    {:ok, match_events_string} = JSON.encode(match_events_list)
    match_events_string
  end

  defp match_score_attributes(match, match_score) do
    [home_goals | [guest_goals]] = parse_match_score(match_score)
    case match.home_match do
      true ->
        %{team_goals: home_goals, opponent_team_goals: guest_goals}
      _    ->
        %{opponent_team_goals: home_goals, team_goals: guest_goals}
    end
  end

  defp parse_match_score(match_score) do
    match_score
    |> String.split(":", trim: true)
    |> Enum.map(fn(x) -> String.to_integer(x) end)
  end
end
