import $ from 'jquery';
window.$ = window.jQuery = window.jquery = $;

import MatchTimelineConstants from "./match_timeline.constants";
import matchStateMethods from './match_timeline.match_state_methods';

import * as moment from 'moment';
import 'moment/locale/de';
window.m = window.moment = moment;

let matchEventButtonHandler = (function() {
  var matchEventButtons           = $('.js-standard-match-event-buttons button');
  var decidingGameButtons         = $('.js-deciding-game-buttons button');
  var penaltyShootOutEventButtons = $('.js-penalty-shoot-out-event-buttons button');
  var matchEventFormSelector      = '.js-match-event-form'
  var matchEventFormEl            = $(matchEventFormSelector);
  var requiredFields = {
    'goal':              ['type', 'minute', 'datetime', 'position', 'text', 'own-goal'],
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
    'continuation':      ['type', 'minute', 'datetime', 'position', 'text', 'event'],
    'quit':              ['type', 'minute', 'datetime', 'position', 'text', 'event']
  };

  var hideEventForm = function() {
    if (matchEventFormEl.is(':visible')) {
      matchEventFormEl.slideUp('fast', function() {
        $(this).removeClass('hidden').find('input[type=text]').val('');
        var flatCheckbox = $(this).find('.flat-checkbox');
        flatCheckbox.find('input').removeProp('checked').removeAttr('checked');
        flatCheckbox.find('label').removeClass('checked')
      });
      MatchTimelineConstants.timelineEl.trigger('match-event:hide-event-form');
    }
  };

  var showEventForm = function(type, position, currentMinute) {
    matchEventFormEl.find('.form-group').addClass('hidden');
    matchEventFormEl.find('input[name=type]').val(type);
    matchEventFormEl.find('input[name=position]').val(position);
    matchEventFormEl.find('input[name=minute]').val(currentMinute);
    matchEventFormEl.find('input[name=datetime]').val(moment().toISOString());
    matchEventFormEl.find('.form-group').removeClass('has-error');
    $.each(requiredFields[type], function(index, field) {
      matchEventFormEl.find('input[name=' + field + ']').closest('.form-group').removeClass('hidden');
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
    MatchTimelineConstants.timelineEl.trigger('match-event:show-event-form');
  };

  var enableDecidingEventButtons = function(indexes, decidingGame, lastMatchEvent) {
    if (decidingGame === true) {
      if (indexes.finalWhistleIndexes.length === 2) {
        if (lastMatchEvent.type === 'final-whistle') {
          matchEventButtons.filter('[data-match-event=penalty-shoot-out]').removeProp('disabled').removeAttr('disabled');
        }
      } else if (
          (indexes.kickOffIndexes.length === 2 && indexes.finalWhistleIndexes.length === 1 && lastMatchEvent.type === 'final-whistle') ||
          (indexes.kickOffIndexes.length === 3 && indexes.halfTimeBreakIndexes.length === 2 && lastMatchEvent.type === 'half-time-break')
        ) {
        matchEventButtons.filter('[data-match-event=kick-off]').removeProp('disabled').removeAttr('disabled');
      } else if (indexes.kickOffIndexes.length === 3 && indexes.halfTimeBreakIndexes.length === 1 && indexes.finalWhistleIndexes.length === 1) {
        matchEventButtons.filter('[data-match-event=half-time-break]').removeProp('disabled').removeAttr('disabled');
      } else if (indexes.kickOffIndexes.length === 4 && indexes.halfTimeBreakIndexes.length === 2 && indexes.finalWhistleIndexes.length === 1) {
        matchEventButtons.filter('[data-match-event=final-whistle]').removeProp('disabled').removeAttr('disabled');
      }
    }
  };

  var enableStartEndEventButtons = function(indexes, decidingGame, lastMatchEvent) {
    if (
        (indexes.kickOffIndexes.length === 0) ||
        (indexes.kickOffIndexes.length === 1 && indexes.halfTimeBreakIndexes.length === 1 && lastMatchEvent.type === 'half-time-break')
        ) {
      matchEventButtons.filter('[data-match-event=kick-off]').removeProp('disabled').removeAttr('disabled');
    } else if (
        (indexes.kickOffIndexes.length === 1 && indexes.halfTimeBreakIndexes.length === 0 && indexes.finalWhistleIndexes.length === 0)
        ) {
      matchEventButtons.filter('[data-match-event=half-time-break], [data-match-event=break], [data-match-event=continuation], [data-match-event=quit]').removeProp('disabled').removeAttr('disabled');
    } else if (
        (indexes.kickOffIndexes.length === 2 && indexes.halfTimeBreakIndexes.length === 1 && indexes.finalWhistleIndexes.length === 0) ||
        (indexes.kickOffIndexes.length === 4 && indexes.halfTimeBreakIndexes.length === 2 && indexes.finalWhistleIndexes.length === 1)
        ) {
      matchEventButtons.filter('[data-match-event=final-whistle], [data-match-event=quit]').removeProp('disabled').removeAttr('disabled');
    }
  };

  var enableMatchEventButtons = function(indexes) {
    if (
        (indexes.kickOffIndexes.length === 1 && indexes.halfTimeBreakIndexes.length === 0) || 
        (indexes.kickOffIndexes.length === 2 && indexes.finalWhistleIndexes.length === 0)  || 
        (indexes.kickOffIndexes.length === 3 && indexes.halfTimeBreakIndexes.length === 1) || 
        (indexes.kickOffIndexes.length === 4 && indexes.finalWhistleIndexes.length === 1)
        ) {
      matchEventButtons.filter('[data-match-event=break]').removeProp('disabled').removeAttr('disabled');
      matchEventButtons.filter('[data-match-event=quit]').removeProp('disabled').removeAttr('disabled');
      matchEventButtons.filter('[data-match-event=goal]').removeProp('disabled').removeAttr('disabled');
      matchEventButtons.filter('[data-match-event=penalty]').removeProp('disabled').removeAttr('disabled');
      matchEventButtons.filter('[data-match-event=replacement]').removeProp('disabled').removeAttr('disabled');
      matchEventButtons.filter('[data-match-event=foul-yellow]').removeProp('disabled').removeAttr('disabled');
      matchEventButtons.filter('[data-match-event=foul-yellow-red]').removeProp('disabled').removeAttr('disabled');
      matchEventButtons.filter('[data-match-event=foul-red]').removeProp('disabled').removeAttr('disabled');
    }
  };

  var buttonSwitcher = function() {
    var decidingGame   = detectDecidingGame();
    var allMatchEvents = MatchTimelineConstants.timelineEl.data('match-events') || [];
    var lastMatchEvent = allMatchEvents[(allMatchEvents.length - 1)];
    var indexes = matchStateMethods.finalEventIndexes(allMatchEvents);

    matchEventButtons.prop('disabled', 'disabled').attr('disabled', 'disabled');

    if (allMatchEvents.length === 0 || (!_.isEmpty(lastMatchEvent) && lastMatchEvent.type !== 'quit')) {
      enableDecidingEventButtons(indexes, decidingGame, lastMatchEvent);
      enableStartEndEventButtons(indexes, decidingGame, lastMatchEvent);
      enableMatchEventButtons(indexes);
      switchDecidingGameButtonsVisibility(decidingGame);
      breakContinuationButtonSwitch(allMatchEvents);
    }
  };

  var breakContinuationButtonSwitch = function(allMatchEvents) {
    var lastMatchEvent = _.last(allMatchEvents);
    if (!_.isEmpty(lastMatchEvent) && lastMatchEvent.type === 'break') {
      matchEventButtons.prop('disabled', 'disabled').attr('disabled', 'disabled');
      matchEventButtons.filter('[data-match-event=break]').
        removeProp('disabled').removeAttr('disabled').
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

  var detectDecidingGame = function() {
    return MatchTimelineConstants.timelineEl.data('match-character') === 'deciding-game';
  };

  var switchDecidingGameButtonsVisibility = function(decidingGame) {
    var allMatchEvents = MatchTimelineConstants.timelineEl.data('match-events') || [];
    var decidingGameButtonsParent = $('.js-deciding-game-buttons');
    var indexes = matchStateMethods.finalEventIndexes(allMatchEvents);
    if (
        matchStateMethods.isPenaltyShootOutOver(allMatchEvents) === true || 
        (decidingGame === false && indexes.finalWhistleIndexes.length === 1)
        ) {
      $('.js-standard-match-event-buttons').addClass('hidden');
      $('.js-penalty-shoot-out-event-buttons').addClass('hidden');
      decidingGameButtonsParent.addClass('hidden');
      decidingGameButtons.prop('disabled', 'disabled').attr('disabled', 'disabled');
      penaltyShootOutEventButtons.prop('disabled', 'disabled').attr('disabled', 'disabled');
    } else if (decidingGame === true && matchStateMethods.isPenaltyShootOutPossible(allMatchEvents) === true) {
      $('.js-standard-match-event-buttons').addClass('hidden');
      $('.js-penalty-shoot-out-event-buttons').removeClass('hidden');
      decidingGameButtonsParent.removeClass('hidden');
      decidingGameButtons.filter('[data-match-event=penalty-shoot-out]').removeProp('disabled').removeAttr('disabled');
      penaltyShootOutEventButtons.prop('disabled', 'disabled').attr('disabled', 'disabled');
    } else if (
        decidingGame === true && (
          matchStateMethods.isPenaltyShootOutStart(allMatchEvents) === true ||
          matchStateMethods.isPenaltyShootOut(allMatchEvents) === true
        )
        ) {
      $('.js-standard-match-event-buttons').addClass('hidden');
      $('.js-penalty-shoot-out-event-buttons').removeClass('hidden');
      decidingGameButtonsParent.removeClass('hidden');
      decidingGameButtons.filter('[data-match-event=penalty-shoot-out]').prop('disabled', 'disabled').attr('disabled', 'disabled');
      decidingGameButtons.filter('[data-match-event=final-whistle]').removeProp('disabled').removeAttr('disabled');


      var lastMatchEvent = _.last(allMatchEvents);
      if (['penalty-goal', 'no-penalty-goal'].indexOf(lastMatchEvent.type) > -1) {
        var positions = ['left', 'right'];
        var lastEventPositionIndex = _.findIndex(positions, function(position){ return position === lastMatchEvent.position; });
        var nextPenaltyShootOutEventButtonsPosition = Math.abs(lastEventPositionIndex - 1);
        penaltyShootOutEventButtons.filter('[data-match-event-position=' + positions[lastEventPositionIndex] + ']').prop('disabled', 'disabled').attr('disabled', 'disabled');
        penaltyShootOutEventButtons.filter('[data-match-event-position=' + positions[nextPenaltyShootOutEventButtonsPosition] + ']').removeProp('disabled').removeAttr('disabled');
      } else {
        penaltyShootOutEventButtons.removeProp('disabled').removeAttr('disabled');
      }

    } else if (!matchStateMethods.isPenaltyShootOutOver(allMatchEvents)) {
      $('.js-standard-match-event-buttons').removeClass('hidden');
      $('.js-penalty-shoot-out-event-buttons').addClass('hidden');
      decidingGameButtonsParent.addClass('hidden');
      decidingGameButtons.prop('disabled', 'disabled').attr('disabled', 'disabled');
      penaltyShootOutEventButtons.prop('disabled', 'disabled').attr('disabled', 'disabled');
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
    var ret = 0;
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

  var humanTime = function() {
    return moment().format('LT') + ' ' + matchStateMethods.translate('o_clock');
  };

  var addEventOrShowEventForm = function(type, position) {
    var allMatchEvents = MatchTimelineConstants.timelineEl.data('match-events') || [];
    var currentMinute  = calculateMinute(allMatchEvents, type);
    var events = {
      'kick-off': {"type":"kick-off","event":matchStateMethods.translate('kick-off'),"text":humanTime(),"minute":currentMinute,"datetime":moment().toISOString(),"position":"bottom"},
      'final-whistle': {"type":"final-whistle","event":matchStateMethods.translate('final-whistle'),"text":humanTime() + "<br />" + matchStateMethods.translate('final-score') + ": " + matchStateMethods.matchScore() + matchStateMethods.finalWhistleTextAddition(allMatchEvents),"minute":currentMinute,"datetime":moment().toISOString(),"position":"top"},
      'half-time-break': {"type":"half-time-break","event":matchStateMethods.translate('half-time-break'),"text":humanTime() + "<br />" + matchStateMethods.translate('match-score') + ": " + matchStateMethods.matchScore(),"minute":currentMinute,"datetime":moment().toISOString(),"position":"top"},
      'goal': showEventForm, 
      'penalty': showEventForm, 
      'replacement': showEventForm, 
      'penalty-goal': showEventForm, 
      'no-penalty-goal': showEventForm, 
      'foul-yellow': showEventForm, 
      'foul-yellow-red': showEventForm, 
      'foul-red': showEventForm,
      'penalty-shoot-out': {"type":"penalty-shoot-out","event":matchStateMethods.translate('penalty-shoot-out'),"text":humanTime(),"minute":currentMinute,"datetime":moment().toISOString(),"position":"bottom"},
      'break': {"type":"break","event":matchStateMethods.translate('break'),"text":humanTime(),"minute":currentMinute,"datetime":moment().toISOString(),"position":"top"},
      'continuation': {"type":"continuation","event":matchStateMethods.translate('continuation'),"text":humanTime(),"minute":currentMinute,"datetime":moment().toISOString(),"position":"bottom"},
      'quit': {"type":"quit","event":matchStateMethods.translate('quit'),"text":humanTime(),"minute":currentMinute,"datetime":moment().toISOString(),"position":"top"}
    };
    var ret = events[type];
    if (type === 'final-whistle') {
      var indexes = matchStateMethods.finalEventIndexes(allMatchEvents);
      if (indexes.finalWhistleIndexes.length === 2) {
        ret.minute = '';
      }
    }
    if (typeof(ret) === 'object') {
      MatchTimelineConstants.timelineEl.trigger('match-event:add', ret);
    } else if (typeof(ret) === 'function') {
      ret(type, position, currentMinute);
    }
    return allMatchEvents;
  };

  var addFinalWhistleEvent = function() {
    addEventOrShowEventForm('final-whistle', 'top');
  };

  var submitMatchEvent = function() {
    var type = matchEventFormEl.find('input[name=type]').val().trim();

    /*
    if (['kick-off', 'half-time-break', 'final-whistle'].indexOf(type) > -1) {
      matchEventFormEl.find('input[name=event]').closest('.form-group').removeClass('hidden');
    }
    */

    var ret = {};
    $.each(requiredFields[type], function(index, field) {
      var fieldEl = matchEventFormEl.find('input[name=' + field + ']');
      if (fieldEl.attr('type') === 'checkbox') {
        ret[field] = (fieldEl.prop('checked') || fieldEl.attr('checked') === 'checked').toString();
      } else {
        ret[field] = fieldEl.val();
      }
      if (ret[field].trim() === '' && ['tel', 'text'].indexOf(fieldEl.prop('type')) > -1) {
        fieldEl.closest('.form-group').addClass('has-error');
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
    // match event button event
    $('.js-standard-match-event-buttons button, .js-deciding-game-buttons button, .js-penalty-shoot-out-event-buttons button').click(function() {
      var button = $(this);
      addEventOrShowEventForm(button.data('match-event'), button.data('match-event-position'));
      buttonSwitcher();
    });

    // close button event to delete the last match event
    $(document).on('click', '.js-match-events-timeline button.close', function() {
      var removedElementIndex = parseInt($(this).data('event-index'));
      MatchTimelineConstants.timelineEl.trigger('match-event:remove', removedElementIndex);
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
        MatchTimelineConstants.timelineEl.trigger('match-event:add', eventOrFalse);
      }
      return false;
    });


    $(document)
      .on('match-event:afterAdd', MatchTimelineConstants.timelineSelector, function(event, matchEvent, allMatchEvents) {
        if (matchEvent.type !== 'final-whistle' && matchStateMethods.isPenaltyShootOutOver(allMatchEvents)) {
          addFinalWhistleEvent();
        }
      });
  };

  return {
    init: init,
    hideEventForm: hideEventForm,
    switchButtons: buttonSwitcher,
    addFinalWhistleEvent: addFinalWhistleEvent
  };
})();

export default matchEventButtonHandler;
