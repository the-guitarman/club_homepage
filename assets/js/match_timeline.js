// window.$ = window.jQuery = window.jquery = require('../vendor/js/01_01_jquery.min.js');
// window._ = window.underscore = require('../vendor/js/01_04_underscore.min.js');

// require('../vendor/js/25_soccer-match-timeline.javascript-extensions.js');
// require('../vendor/js/26_soccer-match-timeline.lang.js');
// require('../vendor/js/27_soccer-match-timeline.js');
// require('../vendor/js/28_soccer-match-timeline.events.js');
// require('../vendor/js/29_soccer-match-timeline.extensions.js');

let MatchTimeline = {
  socket: null,
  channel: null,
  matchTimelineSelector: '#match-timeline',
  matchTimelineEl: null,

  getMatchEvents: () => {
    return MatchTimeline.matchTimelineEl.data('match-events') || [];
  },

  getMatchId: () => {
    return MatchTimeline.matchTimelineEl.data("match-id");
  },

  connectAndJoin: () => {
    MatchTimeline.socket.connect();
    MatchTimeline.channel = MatchTimeline.socket.channel("match-timelines:" + MatchTimeline.getMatchId());
    // MatchTimeline.channel.onError((e) => console.log("something went wrong", e));
    // MatchTimeline.channel.onClose((e) => console.log("channel closed", e));

    MatchTimeline.channel.join()
      .receive("ok", (response) => {
        MatchTimeline.renderMatchEvents(response.match_events);
      })
      .receive("error", (reason) => {
        MatchTimeline.renderMatchEvents([]);
      })
      .receive("ignore", () => {
        MatchTimeline.renderMatchEvents([]);
      })
      .receive("timeout", () => {
        MatchTimeline.renderMatchEvents([]);
      })
    ;

    // let startDisconnectTimeout = function() {
    //   var timerId = setTimeout(function(){
    //     MatchTimeline.channel
    //       .push('leave', timerId)
    //       .receive("error", (e) => console.log(e));
    //   }, (5 * 60 * 1000);
    // }
  },

  renderMatchEvents: (matchEvents, removeCloseButton = false) => {
    $(document).ready(function(){
      MatchTimeline.matchTimelineEl.data('match-events', matchEvents)
      matchEventsRenderer.init()
      if (removeCloseButton === true) {
        MatchTimeline.matchTimelineEl.find('button.close').parent().remove()
      }
      matchEventButtonHandler.switchButtons();
      matchEventButtonHandler.hideEventForm();
    });
  },

  canInit: () => {
    return MatchTimeline.matchTimelineEl.length > 0;
  },

  initUIEvents: () => {
    $(document)
      .on('match-event:add', '#match-timeline', function(event, matchEvent) {
        MatchTimeline.channel
          .push('match-event:add', matchEvent)
          .receive("error", e => console.log(e));
      })
      .on('match-event:remove', '#match-timeline', function(event, matchEventIndex) {
        MatchTimeline.channel
          .push('match-event:remove', matchEventIndex)
          .receive("error", e => console.log(e));
      })
    ;
  },

  initChannelEventAdd: () => {
    MatchTimeline.channel
      .on("match-event:add", (payload) => {
        //console.log("matchEvent to add", payload);
        var matchEvents = MatchTimeline.getMatchEvents();
        matchEvents.push(payload['match_event']);
        MatchTimeline.renderMatchEvents(matchEvents);
      });
  },

  initChannelEventRemove: () => {
    MatchTimeline.channel
      .on("match-event:remove", (payload) => {
        //console.log("matchEvent to remove", payload);
        var matchEvents    = MatchTimeline.getMatchEvents();
        var removedElement = matchEvents.splice(payload['match_event_index'], 1)[0];
        MatchTimeline.renderMatchEvents(matchEvents);
      });
  },

  initChannelEvents: () => {
    MatchTimeline.initChannelEventAdd();
    MatchTimeline.initChannelEventRemove();
  },

  init: (socket) => {
    MatchTimeline.socket = socket;
    MatchTimeline.matchTimelineEl = $(MatchTimeline.matchTimelineSelector);

    if (MatchTimeline.canInit()) {
      if (_.isEmpty(MatchTimeline.matchTimelineEl.data('channelize')) === true) {
        MatchTimeline.renderMatchEvents(MatchTimeline.matchTimelineEl.data('match-events'), true);
      } else {
        MatchTimeline.connectAndJoin();
        MatchTimeline.initChannelEvents();
        MatchTimeline.initUIEvents();
      }
    }
  }
}

export default MatchTimeline;
