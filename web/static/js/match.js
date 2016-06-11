let MatchTimeline = {
  init(socket, element) {
    if (!element) {
      return
    }

    socket.onOpen( ev => console.log("OPEN", ev) )
    socket.onError( ev => console.log("ERROR", ev) )
    socket.onClose( e => console.log("CLOSE", e))

    let matchTimelineEl = $(element) //$('#match-timeline')

    let getMatchEvents = function(){
      return matchTimelineEl.data('match-events') || [];
    }

    let renderMatchEvents = function(matchEvents, removeCloseButton = false){
      $(document).ready(function(){
        matchTimelineEl.data('match-events', matchEvents)
        matchEventsRenderer.init()
        if (removeCloseButton === true) {
          matchTimelineEl.find('button.close').parent().remove()
        }
        matchEventButtonHandler.switchButtons();
        matchEventButtonHandler.hideEventForm();
      });
    }

    if (_.isEmpty(matchTimelineEl.data('channelize')) === true) {
      renderMatchEvents(matchTimelineEl.data('match-events'), true)
      return
    }

    let matchId = element.getAttribute("data-match-id")

    socket.connect()
    let matchIdChannel = socket.channel("match-timelines:" + matchId)
    matchIdChannel.onError(e => console.log("something went wrong", e))
    matchIdChannel.onClose(e => console.log("channel closed", e))

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
      .receive("ignore", () => {
        console.log("auth error")
        renderMatchEvents([])
      })
      .receive("timeout", () => {
        console.log("connection interruption")
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
