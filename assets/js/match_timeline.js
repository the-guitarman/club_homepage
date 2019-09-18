import MatchTimelineConstants from "./match_timeline.constants";
import buttonTextTranslator from './match_timeline.button_text_translator';
import formTextTranslator from './match_timeline.form_text_translator';
import matchEventsRenderer from './match_timeline.match_events_renderer';
import matchEventButtonHandler from './match_timeline.match_event_button_handler';
import matchTimelineTranslationProvider from './match_timeline.lang';

let MatchTimeline = {
  socket: null,
  channel: null,
  selector: MatchTimelineConstants.timelineSelector,
  element: MatchTimelineConstants.timelineEl,
 
  getMatchEvents: () => {
    return MatchTimeline.element.data('match-events') || [];
  },

  getMatchId: () => {
    return MatchTimeline.element.data("match-id");
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
      MatchTimeline.element.data('match-events', matchEvents);
      matchEventsRenderer.init();
      if (removeCloseButton === true) {
        MatchTimeline.element.find('button.close').parent().remove();
      }
      matchEventButtonHandler.switchButtons();
      matchEventButtonHandler.hideEventForm();
    });
  },

  canInit: () => {
    return MatchTimeline.element.length > 0;
  },

  initUIEventAdd: () => {
    $(document)
      .on('match-event:add', MatchTimeline.selector, function(event, matchEvent) {
        MatchTimeline.channel
          .push('match-event:add', matchEvent)
          .receive("error", e => console.log(e));
      })
      .on('match-event:afterAdd', MatchTimeline.selector, function(event, matchEvent, matchEvents) {
        matchEventButtonHandler.switchButtons();
        matchEventButtonHandler.hideEventForm();
      });
  },

  initUIEventRemove: () => {
    $(document)
      .on('match-event:remove', MatchTimeline.selector, function(event, matchEventIndex) {
        MatchTimeline.channel
          .push('match-event:remove', matchEventIndex)
          .receive("error", e => console.log(e));
      })
      .on('match-event:afterRemove', MatchTimeline.selector, function(event, removedElementIndex, removedElement, matchEvents) {
        matchEventButtonHandler.switchButtons();
        matchEventButtonHandler.hideEventForm();
      });
  },

  initUIEventShowForm: () => {
    $(document)
      .on('match-event:show-event-form', MatchTimeline.selector, function(event) {
        var matchEventFormEl = $('.js-match-event-form');
        var position = matchEventFormEl.find('input[name=position]').val();
        var inputGroupButtons = matchEventFormEl.find('.input-group-btn');
        inputGroupButtons.addClass('hidden');
        inputGroupButtons.filter('.' + position).removeClass('hidden');
      })
      .on('click', '.js-match-event-form .input-group-btn .dropdown-menu a', function() {
        var self = $(this);
        self.closest('.input-group').find('input').val(self.text());
      });
  },

  initUIEvents: () => {
    MatchTimeline.initUIEventAdd();
    MatchTimeline.initUIEventRemove();
    MatchTimeline.initUIEventShowForm();
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
    MatchTimeline.element = $(MatchTimeline.selector);

    if (MatchTimeline.canInit()) {
      matchTimelineTranslationProvider.init();
      buttonTextTranslator.init();
      formTextTranslator.init();
      matchEventsRenderer.init();
      matchEventButtonHandler.init();

      if (_.isEmpty(MatchTimeline.element.data('channelize')) === true) {
        MatchTimeline.renderMatchEvents(MatchTimeline.element.data('match-events'), true);
      } else {
        MatchTimeline.connectAndJoin();
        MatchTimeline.initChannelEvents();
        MatchTimeline.initUIEvents();
      }
    }
  }
};

export default MatchTimeline;
