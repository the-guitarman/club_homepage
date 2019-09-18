import _ from 'underscore';
window._ = window.underscore = _;

import MatchTimelineConstants from "./match_timeline.constants";
import matchStateMethods from './match_timeline.match_state_methods';
import matchEventCreator from './match_timeline.match_event_creator';

import matchTimelineJavascriptExtensions from './match_timeline.javascript_extensions.js';
matchTimelineJavascriptExtensions.init();

let matchEventsRenderer = {
  matchEvents: function() {
    return MatchTimelineConstants.timelineEl.data('match-events') || [];
  },

  prependToTimeline: function(matchEvent) {
    var html = matchEventCreator.init(matchEvent);
    MatchTimelineConstants.timelineEl.find('.timeline-states').prepend(html);
  },
/*
  htmlEncode: function(value) {
    return $('<div/>').text(value).html();
  },

  htmlDecode: function(value) {
    return $('<div/>').html(value).text();
  },
*/
  differenceMinutes: function(lastMinute, currentMinute) {
    return parseInt(currentMinute) - parseInt(lastMinute);
  },

  eventHeight: function(minutes) {
    return parseInt(minutes); // * 2;
  },

  halfTime: function(allMatchEvents, matchEventIndex, matchEvent) {
    var indexes = [];
    $.each(allMatchEvents, function(index, aMatchEvent) {
      if (['kick-off', 'half-time-break', 'final-whistle'].indexOf(aMatchEvent.type) > -1) {
        indexes.push(index);
      }
    });

    var slices = [];
    _.eachSlice(indexes, 2, function(slice) {
      slices.push(slice);
    });

    var ret = 1;
    for (var i = 0; i < slices.length; i++) {
      var slice = slices[i];
      if (
          (slice.length === 2 && slice[0] <= matchEventIndex && slice[1] >= matchEventIndex) ||
          (slice.length === 1 && slice[0] <= matchEventIndex)
          ) {
        ret = i + 1;
        break;
      }
    }
    return ret;
  },

  addEventAttributes: function(eventIndex, lastMinute, matchEvent, allMatchEvents) {
    matchEvent.eventIndex      = eventIndex;
    matchEvent.lastEventIndex  = allMatchEvents.length - 1;
    matchEvent.eventHeight     = matchEventsRenderer.eventHeight(matchEventsRenderer.differenceMinutes(lastMinute, matchEvent.minute));
    matchEvent.halfTime        = matchEventsRenderer.halfTime(allMatchEvents, eventIndex, matchEvent);
    matchEvent.typeTranslation = matchStateMethods.typeTranslation(matchEvent);
    return matchEvent;
  },

  timelineEvent: function(withMinute, lastMinute, minute) {
    var type = 'timeline';
    if (_.isEmpty(withMinute) === false && withMinute === true) {
      type = type + '+minute';
    }
    return {type:type, minute:minute, eventHeight:matchEventsRenderer.eventHeight(matchEventsRenderer.differenceMinutes(lastMinute, minute))};
  },

  init: function() {
    $('.timeline-states').html('');
    matchStateMethods.initMatchScore();

    var lastMinute = 0;
    var allMatchEvents = matchEventsRenderer.matchEvents();
    $.each(allMatchEvents, function(index, matchEvent) {
      matchEvent = matchEventsRenderer.addEventAttributes(index, lastMinute, matchEvent, allMatchEvents);
      if (index > 0 && ['kick-off', 'break', 'continuation', 'penalty-goal', 'no-penalty-goal'].indexOf(matchEvent.type) === -1) {
        matchEventsRenderer.prependToTimeline(matchEventsRenderer.timelineEvent(false, lastMinute, matchEvent.minute));
      }
      matchStateMethods.countMatchScore(matchEvent);
      matchEventsRenderer.prependToTimeline(matchEvent);
      lastMinute = matchEvent.minute;
    });
  }
};

export default matchEventsRenderer;
