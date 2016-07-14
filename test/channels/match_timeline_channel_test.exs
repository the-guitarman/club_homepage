defmodule ClubHomepage.MatchTimelineChannelTest do
  use ClubHomepage.ChannelCase

  import ClubHomepage.Factory

  alias ClubHomepage.Match
  alias ClubHomepage.MatchTimelineChannel
  alias ClubHomepage.Repo

  setup do
    match = create(:match)
    user  = create(:user)

    {:ok, _, sock} = 
      socket("users_socket: #{user.id}", %{current_user: user})
      |> subscribe_and_join(MatchTimelineChannel, "match-timelines:#{Integer.to_string(match.id)}")

    {:ok, socket: sock, match: match}
  end

  test "match-events", %{socket: socket, match: match} do
    assert match.match_events == nil

    match_events = []

    match_event = %{"type" => "kick-off"}
    ref = push(socket, "match-event:add", match_event)
    assert_reply ref, :ok
    assert_broadcast("match-event:add", match_event)
    # assert_receive %Phoenix.Socket.Broadcast{
    #   topic: "match-timelines:" <> match.id,
    #   event: "match-event:add",
    #   payload: match_event
    # }
    match_events = add_match_event(match_events, match_event)
    assert get_match_events(match) == json_encode(match_events)

    ref = push(socket, "match-event:remove", match_event)
    assert_reply ref, :ok
    assert_broadcast("match-event:remove", _match_event)
    assert get_match_events(match) == json_encode([])

    ref = push(socket, "match-event:final-whistle", "3:2")
    assert_reply ref, :ok
    #:timer.sleep(50)
    assert get_match_score(match) == "3:2"

    leave socket
  end

  defp get_match(match) do
    Repo.get!(Match, match.id)
  end

  defp get_match_events(match) do
    match = get_match(match)
    match.match_events
  end

  defp get_match_score(match) do
    match = get_match(match)
    case match.home_match do
      true -> "#{match.team_goals}:#{match.opponent_team_goals}"
      _ -> "#{match.opponent_team_goals}:#{match.team_goals}"
    end
  end

  defp add_match_event(match_events, match_event) do
    Enum.reverse([match_event | Enum.reverse(match_events)])
  end

  defp json_encode(match_events_list) do
    {:ok, match_events_string} = JSON.encode(match_events_list)
    match_events_string
  end
end
