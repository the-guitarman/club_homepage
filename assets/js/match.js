let MatchTimeline = {
  init(socket, element) {
    if (!element) {
      return
    }

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
      .on("match-event:add", (payload) => {
        //console.log("matchEvent to add", payload)
        let matchEvents = getMatchEvents()
        matchEvents.push(payload['match_event'])
        renderMatchEvents(matchEvents)
      })
 
    matchIdChannel
      .on("match-event:remove", (payload) => {
        //console.log("matchEvent to remove", payload)
        let matchEvents    = getMatchEvents()
        let removedElement = matchEvents.splice(payload['match_event_index'], 1)[0]
        renderMatchEvents(matchEvents)
      })

    matchIdChannel.join()
      .receive("ok", (response) => {
        //console.log("joined the match channel: " + matchId, response.match_events)
        renderMatchEvents(response.match_events)
      })
      .receive("error", (reason) => {
        console.log("join failed", reason)
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

    // let startDisconnectTimeout = function() {
    //   var timerId = setTimeout(function(){
    //     matchIdChannel
    //       .push('leave', timerId)
    //       .receive("error", e => console.log(e));
    //   }, (5 * 60 * 1000);
    // }

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
