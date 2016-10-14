defmodule ClubHomepage.MatchTimelineChannelTest do
  use ClubHomepage.ChannelCase

  import ClubHomepage.Factory
  
  alias ClubHomepage.Competition
  alias ClubHomepage.Match
  alias ClubHomepage.MatchTimelineChannel
  alias ClubHomepage.Repo

  @kick_off_match_event %{"type" => "kick-off"}
  @final_whistles_match_event %{"type" => "final-whistle"}
  @home_goal_match_event %{"type" => "goal", "position" => "left"}
  @home_penalty_match_event %{"type" => "penalty", "position" => "left"}
  @guest_goal_match_event %{"type" => "goal", "position" => "right"}

  setup do
    match = insert(:match)
    user  = insert(:user)

    {:ok, _, sock} = 
      socket("users_socket: #{user.id}", %{current_user: user})
      |> subscribe_and_join(MatchTimelineChannel, "match-timelines:#{match.id}")

    {:ok, socket: sock, match: match}
  end

  test "add and remove match-events", %{socket: socket, match: match} do
    assert match.match_events == nil

    match_events = []

    match_event = %{"type" => "kick-off"}
    ref = push(socket, "match-event:add", %{match_event: match_event})
    assert_reply ref, :ok
    assert_broadcast("match-event:add", %{match_event: match_event})
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

    leave socket
  end

  test "match is finished after three final whistle match events", %{socket: socket, match: match} do
    competition = insert(:competition, %{matches_need_decition: true})
    {:ok, match} =
      Match.changeset(match, %{competition_id: competition.id})
      |> Repo.update

    assert match.team_goals == nil
    assert match.opponent_team_goals == nil

    ref = push(socket, "match-event:add", @final_whistles_match_event)
    assert_reply ref, :ok
    ref = push(socket, "match-event:add", @home_goal_match_event)
    assert_reply ref, :ok
    ref = push(socket, "match-event:add", @guest_goal_match_event)
    assert_reply ref, :ok
    ref = push(socket, "match-event:add", @final_whistles_match_event)
    assert_reply ref, :ok
    ref = push(socket, "match-event:add", @home_penalty_match_event)
    assert_reply ref, :ok
    ref = push(socket, "match-event:add", @final_whistles_match_event)
    assert_reply ref, :ok

    match = Repo.get!(Match, match.id)
    case match.home_match do
      true  -> assert get_match_score(match) == "1:2"
      false -> assert get_match_score(match) == "2:1"
    end
  end

  test "match is finished after two final whistle match events and a team has won", %{socket: socket, match: match} do
    competition = insert(:competition, %{matches_need_decition: true})
    {:ok, match} =
      Match.changeset(match, %{competition_id: competition.id})
      |> Repo.update

    assert match.team_goals == nil
    assert match.opponent_team_goals == nil

    ref = push(socket, "match-event:add", @final_whistles_match_event)
    assert_reply ref, :ok
    ref = push(socket, "match-event:add", @home_goal_match_event)
    assert_reply ref, :ok
    ref = push(socket, "match-event:add", @guest_goal_match_event)
    assert_reply ref, :ok
    ref = push(socket, "match-event:add", @home_penalty_match_event)
    assert_reply ref, :ok
    ref = push(socket, "match-event:add", @final_whistles_match_event)
    assert_reply ref, :ok

    match = Repo.get!(Match, match.id)
    case match.home_match do
      true  -> assert get_match_score(match) == "1:2"
      false -> assert get_match_score(match) == "2:1"
    end
  end

  test "match is finished after a final whistle match event and if it's no deciding game", %{socket: socket, match: match} do
    competition = Repo.get!(Competition, match.competition_id)
    assert competition.matches_need_decition == false

    assert match.team_goals == nil
    assert match.opponent_team_goals == nil

    ref = push(socket, "match-event:add", @home_goal_match_event)
    assert_reply ref, :ok
    ref = push(socket, "match-event:add", @guest_goal_match_event)
    assert_reply ref, :ok
    ref = push(socket, "match-event:add", @home_penalty_match_event)
    assert_reply ref, :ok
    ref = push(socket, "match-event:add", @final_whistles_match_event)
    assert_reply ref, :ok

    match = Repo.get!(Match, match.id)
    case match.home_match do
      true  -> assert get_match_score(match) == "1:2"
      false -> assert get_match_score(match) == "2:1"
    end
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
