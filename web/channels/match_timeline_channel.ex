defmodule ClubHomepage.MatchTimelineChannel do
  use ClubHomepage.Web, :channel

  def join("match-timelines:" <> match_id, _params, socket) do
    :timer.send_interval(5_000, :ping) 
    {:ok, assign(socket, :match_id, match_id)}
  end

  # For now, know that handle_in receives direct channel events, handle_out intercepts broadcast events, and handle_info receives OTP messages.
  def handle_info(:ping, socket) do
    count = socket.assigns[:count] || 1
    push socket, "ping", %{count: count}

    {:noreply, assign(socket, :count, count + 1)}
  end
end
