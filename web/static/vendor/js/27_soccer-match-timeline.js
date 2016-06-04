$(document).ready(function() {
  var matchEventsEl = $('.js-match-events');

  moment.locale('en');

  var matchStateMethods = {
    translations: matchEventsEl.data('translations'),

    translate: function(text) {
      var ret = '';
      if (!_.isEmpty(matchStateMethods.translations) && !_.isEmpty(matchStateMethods.translations[text])) {
        ret = matchStateMethods.translations[text];
      }
      return ret;
    },

    breakEventButtonTranslation: function() {
      var abbreviation = matchStateMethods.translate('for-example-abbr');
      return matchStateMethods.translate('break') + '<br />' + 
        '<small>(<abbr title="' + abbreviation[1] + '">' + abbreviation[0] + '</abbr> ' + matchStateMethods.translate('weather') + ')</small>';
    },

    finalEventIndexes: function(allMatchEvents) {
      var kickOffIndexes       = [];
      var halfTimeBreakIndexes = [];
      var finalWhistleIndexes  = [];
      var breakIndexes         = [];
      var continuationIndexes  = [];

      $.each(allMatchEvents, function(index, matchEvent) {
        if (matchEvent.type === 'kick-off') {
          kickOffIndexes.push(index);
        } else if (matchEvent.type === 'half-time-break') {
          halfTimeBreakIndexes.push(index);
        } else if (matchEvent.type === 'final-whistle') {
          finalWhistleIndexes.push(index);
        } else if (matchEvent.type === 'break') {
          breakIndexes.push(index);
        } else if (matchEvent.type === 'continuation') {
          continuationIndexes.push(index);
        }
      });

      return {
        kickOffIndexes: kickOffIndexes, 
        halfTimeBreakIndexes: halfTimeBreakIndexes,
        finalWhistleIndexes: finalWhistleIndexes,
        breakIndexes: breakIndexes,
        continuationIndexes: continuationIndexes
      };
    },

    halfTimeNumber: function(allMatchEvents) {
      var indexes = matchStateMethods.finalEventIndexes(allMatchEvents);

      var ret = 1;
      if (indexes.kickOffIndexes.length > 0) {
        if (indexes.halfTimeBreakIndexes.length > 0) {
          if (indexes.finalWhistleIndexes.length > 0) {
            if (indexes.finalWhistleIndexes.length === 2) {
              ret = 5;
            } else if (indexes.finalWhistleIndexes.length === 1 && indexes.halfTimeBreakIndexes.length === 2) {
              ret = 4;
            } else if (indexes.finalWhistleIndexes.length === 1 && indexes.halfTimeBreakIndexes.length === 1) {
              ret = 3;
            }
          } else {
            ret = 2;
          }
        }
      }
      return ret;
    },

    lastEventOf: function(allMatchEvents, type) {
      var ret = null;
      var index = _.findLastIndex(allMatchEvents, {type: type});
      if (index > -1) {
        ret = allMatchEvents[index];
      }
      return ret;
    },

    halfTimeStartMinute: function(halfTimeNumber) {
      var h = {1:0, 2:45, 3:90, 4:105};
      return h[halfTimeNumber];
    },

    halfTimeMinutes: function(halfTimeNumber) {
      var h = {1:45, 2:45, 3:15, 4:15};
      return h[halfTimeNumber];
    },

    matchScoreUndecided: function() {
      var score = matchEventsEl.data('match-score').split(':');
      return parseInt(score[0]) === parseInt(score[1]);
    },

    isPenaltyShootOutIsOver: function(allMatchEvents) {
      var ret = false;
      var penaltyShootOutIndex  = _.findLastIndex(allMatchEvents, {type: 'penalty-shoot-out'});
      var lastFinalWhistleIndex = _.findLastIndex(allMatchEvents, {type: 'final-whistle'});
      if (penaltyShootOutIndex > -1 && lastFinalWhistleIndex > penaltyShootOutIndex) {
        ret = true;
      }
      return ret;
    },

    isPenaltyShootOut: function(allMatchEvents) {
      var ret = false;
      var penaltyShootOutIndex  = _.findLastIndex(allMatchEvents, {type: 'penalty-shoot-out'});
      var lastFinalWhistleIndex = _.findLastIndex(allMatchEvents, {type: 'final-whistle'});
      if (penaltyShootOutIndex > -1 && lastFinalWhistleIndex < penaltyShootOutIndex) {
        ret = true;
      }
      return ret;
    },

    isPenaltyShootOutStart: function(allMatchEvents, type) {
      var ret = false;
      if (allMatchEvents.length > 0) {
        ret = type === 'penalty-shoot-out' || _.last(allMatchEvents).type === 'penalty-shoot-out';
      }
      return ret;
    },

    isPenaltyShootOutPossible: function(allMatchEvents) {
      var indexes = matchStateMethods.finalEventIndexes(allMatchEvents);
      return (
        indexes.finalWhistleIndexes.length === 2 && 
        matchStateMethods.matchScoreUndecided() === true &&
        _.last(allMatchEvents).type === 'final-whistle'
      );
    },

    initMatchScore: function() {
      var score = '0:0';
      matchEventsEl.data('match-score', score);
      return score;
    },

    matchScore: function() {
      return matchEventsEl.data('match-score');
    },

    countMatchScore: function(matchEvent) {
      var score = matchStateMethods.matchScore();
      if (['goal', 'penalty', 'penalty-goal'].indexOf(matchEvent.type) > -1) {
        score = score.split(':');
        var scorePositionIndexes = {'left':0, 'right':1};
        var scoreIndex = scorePositionIndexes[matchEvent.position];
        score[scoreIndex] = parseInt(score[scoreIndex]) + 1;
        score = score.join(':');
        matchEventsEl.data('match-score', score);
      }
      return score;
    }
  };




  var buttonTextTranslator = (function() {
    var noTransations = ['foul-yellow', 'foul-yellow-red', 'foul-red'];

    var specials = {
      break: matchStateMethods.breakEventButtonTranslation()
    };

    var init = function() {
      var buttons = $('.js-match-event-buttons button');
      $.each(buttons, function(index, button) {
        button = $(button);
        var matchEvent = button.data('match-event');
        if (noTransations.indexOf(matchEvent) === -1) {
          var translation = specials[matchEvent];
          if (_.isEmpty(translation) === true) {
            translation = matchStateMethods.translate(matchEvent);
          }
          var subElement = button.find('img, span');
          if (subElement.length > 0) {
            button.attr('title', translation);
          } else {
            button.html(translation);
          }
        }
      });
    };

    return {init: init};
  })();
  buttonTextTranslator.init();




  var matchEventCreator = (function(){
    var matchEventsEl = $('.js-match-events');

    var minute = function(matchEvent) {
      var ret = '';
      if (['penalty-goal', 'no-penalty-goal'].indexOf(matchEvent.type) > -1) {
        ret = '<div class="timeline-icon timeline-center penalty-shoot-out"></div>';
      } else if (matchEvent.type != 'penalty-shoot-out') {
        var minute = parseInt(matchEvent.minute);
        if (!_.isNaN(minute)) {
          var lastMinute = 
            matchStateMethods.halfTimeStartMinute(matchEvent.halfTime) + 
            matchStateMethods.halfTimeMinutes(matchEvent.halfTime);

          if (matchEvent.minute > lastMinute) {
            minute = lastMinute + "+" + (matchEvent.minute - lastMinute);
          }

          ret = '<div class="timeline-icon timeline-center">\'' + minute + '</div>';
        }
      }
      return ret;
    };

    var concatText = function(text1, text2, matchEventType) {
      var ret = text1 + ' ' + text2;
      if (['goal', 'penalty', 'replacement', 'penalty-goal', 'no-penalty-goal'].indexOf(matchEventType) > -1) {
        ret = text1 + ', ' + text2;
      }
      return ret;
    };

    var contentAlignment = function(html, matchEvent) {
      if (matchEvent.position === 'left') {
        if (matchEvent.text.trim() != '') {
          html = concatText(matchEvent.text, html, matchEvent.type);
        }
      } else if (matchEvent.position === 'right') {
        if (matchEvent.text.trim() != '') {
          html = concatText(html, matchEvent.text, matchEvent.type);
        }
      } else {
        html = '<strong>' + matchEvent.event + '</strong><br />' + matchEvent.text;
      }
      return html;
    };

    var foulHTML = function(matchEventType) {
      var ret = '';
      if (matchEventType === 'foul-yellow') {
        ret = '<span class="foul-card yellow"></span>';
      } else if (matchEventType === 'foul-red') {
        ret = '<span class="foul-card red"></span>';
      } else if (matchEventType === 'foul-yellow-red') {
        ret = foulHTML('foul-yellow') + foulHTML('foul-red');
      }
      return ret;
    };

    var content = function(matchEvent) {
      var html = '<p>';
      if (['goal', 'penalty', 'penalty-goal', 'no-penalty-goal'].indexOf(matchEvent.type) > -1) {
        var soccerBallImage = '';
        if (matchEvent.type === 'penalty-goal') {
          soccerBallImage = '<img src="images/timeline/soccer_ball_green_24x24.png" alt="" />';
        } else if (matchEvent.type === 'no-penalty-goal') {
          soccerBallImage = '<img src="images/timeline/soccer_ball_red_24x24.png" alt="" />';
        } else {
          soccerBallImage = '<img src="images/timeline/soccer_ball_24x24.png" alt="" />';
        }
        var text = soccerBallImage + ' ' + matchEvent.typeTranslation;
        if (matchEvent.position === 'left') {
          text = matchEvent.typeTranslation + ' ' + soccerBallImage;
        }
        html = html + contentAlignment(text, matchEvent);
      } else if (matchEvent.type === 'replacement') {
        var image = '<img src="images/timeline/replacement_24x24.png" class="replacement" alt="" />';
        var text = image + ' ' + matchEvent.typeTranslation;
        if (matchEvent.position === 'left') {
          text = matchEvent.typeTranslation + ' ' + image;
        }
        matchEvent.text = matchEvent['text-in'] + ' for ' + matchEvent['text-out'];
        html = html + contentAlignment(text, matchEvent);
      } else if (_.contains(['foul-yellow', 'foul-yellow-red', 'foul-red'], matchEvent.type)) {
        html = html + contentAlignment(foulHTML(matchEvent.type), matchEvent);
      } else {
        html = html + '<strong>' + matchEvent.event + '</strong><br />' + matchEvent.text;
      }
      return html + '</p>';
    }

    var contentCt = function(matchEvent) {
      var html = '';
      if (matchEvent.type != "timeline+minute") {
        html = '<div class="timeline-content">' + content(matchEvent) + '</div>';
      } else {
        matchEvent.position = 'top';
        html = '<div class="timeline-content">' + matchStateMethods.translate('match-score') + ': ' + matchStateMethods.matchScore() + '</div>';
      }
      return html;
    };

    var point = function(matchEvent) {
      var html = '<div class="timeline-state position-' + matchEvent.position + '">';
      if (matchEvent.eventIndex >= matchEvent.lastEventIndex) {
        html = html +
          '<div class="css-close-button-wrap text-right">' + 
            '<button type="button" class="close" aria-label="Close" data-event-index="' + matchEvent.eventIndex + '" title="' + matchStateMethods.translate('delete-latest-element') + '">' + 
              '<span aria-hidden="true">&times;</span>' +
            '</button>' +
          '</div>';
      }
      if (matchEvent.position === 'bottom') {
        html = html + minute(matchEvent) + contentCt(matchEvent);
      } else {
        html = html + contentCt(matchEvent) + minute(matchEvent);
      }
      return html + '</div>';
    };

    var timeline = function(matchEvent) {
      var ret = '';
      if (matchEvent.eventHeight > 0) {
        ret = '<div style="height: ' + matchEvent.eventHeight + 'px;"></div>';
      }
      return ret;
    };

    var init = function(matchEvent) {
      if (matchEvent.type === 'timeline') {
        return timeline(matchEvent);
      } else if (matchEvent.type === 'timeline+minute') {
        return point(matchEvent) + timeline(matchEvent);
      } else {
        return point(matchEvent);
      }
    };

    return {init: init};
  })();




  var matchEventsRenderer = (function() {
    var matchEventsEl = $('.js-match-events');

    var matchEvents = function() {
      return matchEventsEl.data('match-events') || [];
    };

    var prependToTimeline = function(matchEvent) {
      var html = matchEventCreator.init(matchEvent);
      matchEventsEl.find('.timeline-states').prepend(html);
    };
/*
    function htmlEncode(value){
      return $('<div/>').text(value).html();
    }

    function htmlDecode(value){
      return $('<div/>').html(value).text();
    }
*/
    var differenceMinutes = function(lastMinute, currentMinute) {
      return parseInt(currentMinute) - parseInt(lastMinute);
    };

    var eventHeight = function(minutes) {
      return parseInt(minutes); // * 2;
    };

    var halfTime = function(allMatchEvents, matchEventIndex, matchEvent) {
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
    };

    var addEventAttributes = function(eventIndex, lastMinute, matchEvent, allMatchEvents) {
      matchEvent.eventIndex      = eventIndex;
      matchEvent.lastEventIndex  = allMatchEvents.length - 1;
      matchEvent.eventHeight     = eventHeight(differenceMinutes(lastMinute, matchEvent.minute));
      matchEvent.halfTime        = halfTime(allMatchEvents, eventIndex, matchEvent);
      matchEvent.typeTranslation = matchStateMethods.translate(matchEvent.type);
      return matchEvent;
    };

    var timelineEvent = function(withMinute, lastMinute, minute) {
      var type = 'timeline';
      if (_.isEmpty(withMinute) === false && withMinute === true) {
        type = type + '+minute';
      }
      return {type:type, minute:minute, eventHeight:eventHeight(differenceMinutes(lastMinute, minute))};
    };

    var init = function() {
      $('.timeline-states').html('');
      matchStateMethods.initMatchScore();

      var lastMinute = 0;
      var allMatchEvents = matchEvents();
      $.each(allMatchEvents, function(index, matchEvent) {
        matchEvent = addEventAttributes(index, lastMinute, matchEvent, allMatchEvents);
        if (index > 0 && ['kick-off', 'break', 'continuation', 'penalty-goal', 'no-penalty-goal'].indexOf(matchEvent.type) === -1) {
          prependToTimeline(timelineEvent(false, lastMinute, matchEvent.minute));
        }
        matchStateMethods.countMatchScore(matchEvent);
        prependToTimeline(matchEvent);
        lastMinute = matchEvent.minute;
      });
    };

    return {
      matchEventsEl: matchEventsEl,
      init: init
    };
  })();

  //matchEventsRenderer.matchEventsEl.data('match-events', []);
  matchEventsRenderer.init();




  var matchEventButtonHandler = (function(matchEventsEl) {
    var matchEventButtons           = $('.js-standard-match-event-buttons button');
    var decidingGameButtons         = $('.js-deciding-game-buttons button');
    var penaltyShootOutEventButtons = $('.js-penalty-shoot-out-event-buttons button');
    var matchEventFormSelector      = '.js-match-event-form'
    var matchEventFormEl            = $(matchEventFormSelector);
    var requiredFields = {
      'goal':              ['type', 'minute', 'datetime', 'position', 'text'],
      'penalty':           ['type', 'minute', 'datetime', 'position', 'text'],
      'replacement':       ['type', 'minute', 'datetime', 'position', 'text-out', 'text-in'],
      'penalty-goal':      ['type', 'datetime', 'position', 'text'],
      'no-penalty-goal':   ['type', 'datetime', 'position', 'text'],
      'foul-yellow':       ['type', 'minute', 'datetime', 'position', 'text'],
      'foul-yellow-red':   ['type', 'minute', 'datetime', 'position', 'text'],
      'foul-red':          ['type', 'minute', 'datetime', 'position', 'text'],
      'kick-off':          ['type', 'minute', 'datetime', 'position', 'text', 'event'],
      'half-time-break':   ['type', 'minute', 'datetime', 'position', 'text', 'event'],
      'final-whistle':     ['type', 'minute', 'datetime', 'position', 'text', 'event'],
      'penalty-shoot-out': ['type', 'minute', 'datetime', 'position', 'text', 'event'],
      'break':             ['type', 'minute', 'datetime', 'position', 'text', 'event'],
      'continuation':      ['type', 'minute', 'datetime', 'position', 'text', 'event']
    };

    var hideEventForm = function() {
      matchEventFormEl.slideUp('fast', function() {
        $(this).removeClass('hidden').find('input[type=text]').val('');
      });
    };

    var showEventForm = function(type, position, currentMinute) {
      matchEventFormEl.find('.form-group').addClass('hidden');
      matchEventFormEl.find('input[name=type]').val(type);
      matchEventFormEl.find('input[name=position]').val(position);
      matchEventFormEl.find('input[name=minute]').val(currentMinute);
      matchEventFormEl.find('input[name=datetime]').val(moment().toISOString());
      matchEventFormEl.find('.form-group').removeClass('has-error');
      $.each(requiredFields[type], function(index, field) {
        matchEventFormEl.find('input[name=' + field + ']').parent().removeClass('hidden');
      });
      matchEventFormEl.hide().removeClass('hidden').slideDown('fast', function() {
        matchEventFormEl.find('input:visible').each(function() {
          var self = $(this);
          if (self.val().trim() === '') {
            self.focus();
            return false;
          }
        });
      });
    };

    var enableDecidingEventButtons = function(indexes, decidingGame, lastMatchEvent) {
      if (decidingGame === true) {
        if (indexes.finalWhistleIndexes.length === 2) {
          if (lastMatchEvent.type === 'final-whistle') {
            matchEventButtons.filter('[data-match-event=penalty-shoot-out]').removeProp('disabled');
          }
        } else if (
            (indexes.kickOffIndexes.length === 2 && indexes.finalWhistleIndexes.length === 1 && lastMatchEvent.type === 'final-whistle') ||
            (indexes.kickOffIndexes.length === 3 && indexes.halfTimeBreakIndexes.length === 2 && lastMatchEvent.type === 'half-time-break')
          ) {
          matchEventButtons.filter('[data-match-event=kick-off]').removeProp('disabled');
        } else if (indexes.kickOffIndexes.length === 3 && indexes.halfTimeBreakIndexes.length === 1 && indexes.finalWhistleIndexes.length === 1) {
          matchEventButtons.filter('[data-match-event=half-time-break]').removeProp('disabled');
        } else if (indexes.kickOffIndexes.length === 4 && indexes.halfTimeBreakIndexes.length === 2 && indexes.finalWhistleIndexes.length === 1) {
          matchEventButtons.filter('[data-match-event=final-whistle]').removeProp('disabled');
        }
      }
    };

    var enableStartEndEventButtons = function(indexes, lastMatchEvent) {
      if (
          (indexes.kickOffIndexes.length === 0) ||
          (indexes.kickOffIndexes.length === 1 && indexes.halfTimeBreakIndexes.length === 1 && lastMatchEvent.type === 'half-time-break')
         ) {
        matchEventButtons.filter('[data-match-event=kick-off]').removeProp('disabled');
      } else if (
          (indexes.kickOffIndexes.length === 1 && indexes.halfTimeBreakIndexes.length === 0 && indexes.finalWhistleIndexes.length === 0)
         ) {
        matchEventButtons.filter('[data-match-event=half-time-break]').removeProp('disabled');
        matchEventButtons.filter('[data-match-event=break], [data-match-event=continuation]').removeProp('disabled');
      } else if (
          (indexes.kickOffIndexes.length === 2 && indexes.halfTimeBreakIndexes.length === 1 && indexes.finalWhistleIndexes.length === 0)
         ) {
        matchEventButtons.filter('[data-match-event=final-whistle]').removeProp('disabled');
      }
    };

    var enableMatchEventButtons = function(indexes) {
      if (
          (indexes.kickOffIndexes.length === 1 && indexes.halfTimeBreakIndexes.length === 0) || 
          (indexes.kickOffIndexes.length === 2 && indexes.finalWhistleIndexes.length === 0)  || 
          (indexes.kickOffIndexes.length === 3 && indexes.halfTimeBreakIndexes.length === 1) || 
          (indexes.kickOffIndexes.length === 4 && indexes.finalWhistleIndexes.length === 1)
         ) {
        matchEventButtons.filter('[data-match-event=break]').removeProp('disabled');
        matchEventButtons.filter('[data-match-event=goal]').removeProp('disabled');
        matchEventButtons.filter('[data-match-event=penalty]').removeProp('disabled');
        matchEventButtons.filter('[data-match-event=replacement]').removeProp('disabled');
        matchEventButtons.filter('[data-match-event=foul-yellow]').removeProp('disabled');
        matchEventButtons.filter('[data-match-event=foul-yellow-red]').removeProp('disabled');
        matchEventButtons.filter('[data-match-event=foul-red]').removeProp('disabled');
      }
    };

    var buttonSwitcher = function(allMatchEvents, decidingGame) {
      var lastMatchEvent = allMatchEvents[(allMatchEvents.length - 1)];
      var indexes = matchStateMethods.finalEventIndexes(allMatchEvents);

      matchEventButtons.prop('disabled', 'disabled');

      enableDecidingEventButtons(indexes, decidingGame, lastMatchEvent);
      enableStartEndEventButtons(indexes, lastMatchEvent);
      enableMatchEventButtons(indexes);
      switchDecidingGameButtonsVisibility(decidingGame);
      breakContinuationButtonSwitch(allMatchEvents);
    };

    var breakContinuationButtonSwitch = function(allMatchEvents) {
      var lastMatchEvent = _.last(allMatchEvents);
      if (!_.isEmpty(lastMatchEvent) && lastMatchEvent.type === 'break') {
        matchEventButtons.prop('disabled', 'disabled');
        matchEventButtons.filter('[data-match-event=break]').
          removeProp('disabled').
          data('match-event', 'continuation').
          data('match-event-position', 'bottom').
          html(matchStateMethods.translate('continuation'));
      } else {
        matchEventButtons.filter('[data-match-event=break]').
          data('match-event', 'break').
          data('match-event-position', 'top').
          html(matchStateMethods.breakEventButtonTranslation());
      }
    };

    var detectDecidingGame = function(matchEventsEl) {
      return matchEventsEl.data('match-character') === 'deciding-game';
    };

    var switchDecidingGameButtonsVisibility = function(decidingGame) {
      var allMatchEvents = matchEventsEl.data('match-events') || [];
      var decidingGameButtonsParent = $('.js-deciding-game-buttons');
      var indexes = matchStateMethods.finalEventIndexes(allMatchEvents);
      if (
          matchStateMethods.isPenaltyShootOutIsOver(allMatchEvents) === true || 
          (decidingGame === false && indexes.finalWhistleIndexes.length === 1)
         ) {
        $('.js-standard-match-event-buttons').addClass('hidden');
        $('.js-penalty-shoot-out-event-buttons').addClass('hidden');
        decidingGameButtonsParent.addClass('hidden');
        decidingGameButtons.prop('disabled', 'disabled');
        penaltyShootOutEventButtons.prop('disabled', 'disabled');
      } else if (decidingGame === true && matchStateMethods.isPenaltyShootOutPossible(allMatchEvents) === true) {
        $('.js-standard-match-event-buttons').addClass('hidden');
        $('.js-penalty-shoot-out-event-buttons').removeClass('hidden');
        decidingGameButtonsParent.removeClass('hidden');
        decidingGameButtons.removeProp('disabled');
        penaltyShootOutEventButtons.prop('disabled', 'disabled');
      } else if (
          decidingGame === true && (
            matchStateMethods.isPenaltyShootOutStart(allMatchEvents) === true ||
            matchStateMethods.isPenaltyShootOut(allMatchEvents) === true
          )
         ) {
        $('.js-standard-match-event-buttons').addClass('hidden');
        $('.js-penalty-shoot-out-event-buttons').removeClass('hidden');
        decidingGameButtonsParent.removeClass('hidden');
        decidingGameButtons.filter('[data-match-event=penalty-shoot-out]').prop('disabled', 'disabled');
        decidingGameButtons.filter('[data-match-event=final-whistle]').removeProp('disabled');
        penaltyShootOutEventButtons.removeProp('disabled');
      } else if (!matchStateMethods.isPenaltyShootOutIsOver(allMatchEvents)) {
        $('.js-standard-match-event-buttons').removeClass('hidden');
        $('.js-penalty-shoot-out-event-buttons').addClass('hidden');
        decidingGameButtonsParent.addClass('hidden');
        decidingGameButtons.prop('disabled', 'disabled');
        penaltyShootOutEventButtons.prop('disabled', 'disabled');
      }
    };

    var calculateBreakMinutes = function(allMatchEvents, type) {
      var ret = 0;
      var indexes = matchStateMethods.finalEventIndexes(allMatchEvents);
      if (indexes.breakIndexes.length > 0) {
        var lastKickOffIndex = indexes.kickOffIndexes[indexes.kickOffIndexes.length - 1];
        if (indexes.breakIndexes.length === indexes.continuationIndexes.length) {
          var breakEvent = null;
          var continuationEvent = null;
          $.each(indexes.breakIndexes, function(index, eventIndex) {
            if (eventIndex > lastKickOffIndex) {
              breakEvent        = allMatchEvents[eventIndex];
              continuationEvent = allMatchEvents[(eventIndex + 1)];
              ret = moment(continuationEvent.datetime).diff(breakEvent.datetime, 'minutes');
            }
          });
        } else if (type === 'continuation') {
          var lastBreakIndex = indexes.breakIndexes[indexes.breakIndexes.length - 1];
          if (lastKickOffIndex < lastBreakIndex) {
            var breakEvent = allMatchEvents[lastBreakIndex];
            ret = moment().diff(breakEvent.datetime, 'minutes') + 1;
          }
        }
      }
      return ret;
    };

    var calculateMinute = function(allMatchEvents, type) {
      ret = 0;
      if (allMatchEvents.length > 0) {
        if (matchStateMethods.isPenaltyShootOutStart(allMatchEvents, type) === false) {           
          var halfTimeNumber = matchStateMethods.halfTimeNumber(allMatchEvents);
          ret = matchStateMethods.halfTimeStartMinute(halfTimeNumber);

          if (type != 'kick-off') {
            var lastKickOffEvent = matchStateMethods.lastEventOf(allMatchEvents, 'kick-off');
            ret = ret + moment().diff(lastKickOffEvent.datetime, 'minutes');
            ret = ret - calculateBreakMinutes(allMatchEvents, type);
          }
        } else {
          ret = '';
        }
      }
      return ret;
    };

    var addEventOrShowEventForm = function(allMatchEvents, type, position) {
      var currentMinute = calculateMinute(allMatchEvents, type);
      var events = {
        'kick-off': {"type":"kick-off","event":matchStateMethods.translate('kick-off'),"text":moment().format('LT'),"minute":currentMinute,"datetime":moment().toISOString(),"position":"bottom"},
        'final-whistle': {"type":"final-whistle","event":matchStateMethods.translate('final-whistle'),"text":moment().format('LT') + "<br />" + matchStateMethods.translate('final-score') + ": " + matchStateMethods.matchScore(),"minute":currentMinute,"datetime":moment().toISOString(),"position":"top"},
        'half-time-break': {"type":"half-time-break","event":matchStateMethods.translate('half-time-break'),"text":moment().format('LT') + "<br />" + matchStateMethods.translate('match-score') + ": " + matchStateMethods.matchScore(),"minute":currentMinute,"datetime":moment().toISOString(),"position":"top"},
        'goal': showEventForm, 
        'penalty': showEventForm, 
        'replacement': showEventForm, 
        'penalty-goal': showEventForm, 
        'no-penalty-goal': showEventForm, 
        'foul-yellow': showEventForm, 
        'foul-yellow-red': showEventForm, 
        'foul-red': showEventForm,
        'penalty-shoot-out': {"type":"penalty-shoot-out","event":matchStateMethods.translate('penalty-shoot-out'),"text":moment().format('LT'),"minute":currentMinute,"datetime":moment().toISOString(),"position":"bottom"},
        'break': {"type":"break","event":matchStateMethods.translate('break'),"text":moment().format('LT'),"minute":currentMinute,"datetime":moment().toISOString(),"position":"top"},
        'continuation': {"type":"continuation","event":matchStateMethods.translate('continuation'),"text":moment().format('LT'),"minute":currentMinute,"datetime":moment().toISOString(),"position":"bottom"}
      };
      var ret = events[type];
      if (type === 'final-whistle') {
        var indexes = matchStateMethods.finalEventIndexes(allMatchEvents);
        if (indexes.finalWhistleIndexes.length === 2) {
          ret.minute = '';
        }
      }
      if (typeof(ret) === 'object') {
        allMatchEvents.push(ret);
      } else if (typeof(ret) === 'function') {
        ret(type, position, currentMinute);
      }
      return allMatchEvents;
    };

    var submitMatchEvent = function() {
      var type = matchEventFormEl.find('input[name=type]').val().trim();

      if (['kick-off', 'half-time-break', 'final-whistle'].indexOf(type) > -1) {
        matchEventFormEl.find('input[name=event]').parent().removeClass('hidden');
      }

      var ret = {};
      $.each(requiredFields[type], function(index, field) {
        var fieldEl = matchEventFormEl.find('input[name=' + field + ']');
        ret[field] = fieldEl.val();
        if (ret[field].trim() === '' && ['tel', 'text'].indexOf(fieldEl.prop('type')) > -1) {
          fieldEl.parent().addClass('has-error');
        }
      });

      if (_.any(ret, function(value, key) {return value.trim() === '';})) {
        ret = false;
      } else if (['goal', 'penalty', 'penalty-goal', 'no-penalty-goal'].indexOf(type) > -1) {
        var matchScore = matchStateMethods.countMatchScore(ret);
        if (ret['position'] === 'left') {
          ret['text'] = matchScore + ' ' + ret['text'];
        } else {
          ret['text'] =  ret['text'] + ' ' + matchScore;
        }
      }

      return ret;
    };

    var init = function() {
      var decidingGame = detectDecidingGame(matchEventsEl);

      // match event button event
      $('.js-standard-match-event-buttons button, .js-deciding-game-buttons button, .js-penalty-shoot-out-event-buttons button').click(function() {
        var button = $(this);
        var matchEvents = matchEventsEl.data('match-events') || [];
        var newMatchEvents = addEventOrShowEventForm(matchEvents, button.data('match-event'), button.data('match-event-position'));
        matchEventsEl.data('match-events', newMatchEvents);
        matchEventsRenderer.init();
        buttonSwitcher(newMatchEvents, decidingGame);
      });

      // close button event to delete the last match event
      $(document).on('click', '.js-match-events-timeline button.close', function() {
        var matchEvents = matchEventsEl.data('match-events') || [];
        matchEvents.splice(parseInt($(this).data('event-index')), 1);
        matchEventsEl.data('match-events', matchEvents);
        matchEventsRenderer.init();
        buttonSwitcher(matchEvents, decidingGame);
        //hideEventForm();
      });




      // match event form reset event
      $(document).on('click', matchEventFormSelector + ' input[type=reset]', function(e) {
        e.preventDefault();
        hideEventForm();
        return false;
      });

      // match event form submit event
      $(document).on('click', matchEventFormSelector + ' input[type=submit]', function(e) {
        e.preventDefault();
        var eventOrFalse = submitMatchEvent();
        if (eventOrFalse != false) {
          var matchEvents = matchEventsEl.data('match-events') || [];
          matchEvents.push(eventOrFalse);
          matchEventsEl.data('match-events', matchEvents);
          matchEventsRenderer.init();
          buttonSwitcher(matchEvents, decidingGame);
          hideEventForm();
        }
        return false;
      });
    };

    return {init: init};
  })(matchEventsRenderer.matchEventsEl);

  matchEventButtonHandler.init();
});