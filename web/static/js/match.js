let MatchTimeline = {
  init(socket, element) {
    if (!element) {
      return
    }

    let matchId = element.getAttribute("data-match-id")

    socket.connect()
    let matchIdChannel = socket.channel("match-timelines:" + matchId)

    matchIdChannel.join()
      .receive("ok", resp => console.log("joined the match channel: " + matchId, resp) )
      .receive("error", reason => console.log("join failed: " + matchId, reason) )

      .on("ping", ({count}) => console.log("PING", count) )
  }
}

export default MatchTimeline
