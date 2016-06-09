let MatchTimeline = {
  init(socket, element) {
    if (!element) {
      return
    }

    let matchTimelineEl = $('#match-timeline')

    let getMatchEvents = function(){
      return matchTimelineEl.data('match-events') || [];
    }

    let renderMatchEvents = function(matchEvents){
      matchTimelineEl.data('match-events', matchEvents)
      matchEventsRenderer.init()
      matchEventButtonHandler.switchButtons();
      matchEventButtonHandler.hideEventForm();
    }

    let matchId = element.getAttribute("data-match-id")

    socket.connect()
    let matchIdChannel = socket.channel("match-timelines:" + matchId)

    matchIdChannel
      .on("match-event:add", (matchEvent) => {
        //console.log("matchEvent to add", matchEvent)
        let matchEvents = getMatchEvents()
        matchEvents.push(matchEvent)
        renderMatchEvents(matchEvents)
      })
 
    matchIdChannel
      .on("match-event:remove", (matchEventIndex) => {
        //console.log("matchEvent to remove", matchEventIndex)
        let matchEvents    = getMatchEvents()
        let removedElement = matchEvents.splice(matchEventIndex, 1)[0]
        renderMatchEvents(matchEvents)
      })

    matchIdChannel.join()
      .receive("ok", (response) => {
        //console.log("joined the match channel: " + matchId, response.match_events)
        renderMatchEvents(response.match_events)
      })
      .receive("error", (reason) => {
        console.log("join failed: " + matchId, reason)
        renderMatchEvents([])
      })

    $(document)
      .on('match-event:add', '#match-timeline', function(event, matchEvent) {
        matchIdChannel
          .push('match-event:add', matchEvent)
          .receive("error", e => console.log(e));
      })
      .on('match-event:remove', '#match-timeline', function(event, matchEventIndex) {
        matchIdChannel
          .push('match-event:remove', matchEventIndex)
          .receive("error", e => console.log(e));

      });
  }
}

export default MatchTimeline
