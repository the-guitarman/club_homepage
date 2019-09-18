import MatchTimelineConstants from './match_timeline.constants';
import _ from 'underscore';

let matchStateMethods = {
  translations: {},

  getTranslations: () => {
    if (_.isEmpty(matchStateMethods.translations)) {
      matchStateMethods.translations = MatchTimelineConstants.timelineEl.data('translations');
    }
  },

  translate: function(text) {
    var ret = '';
    matchStateMethods.getTranslations();
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

  typeTranslation: function(matchEvent) {
      var ret = matchStateMethods.translate(matchEvent.type);
      if (matchEvent.type === 'goal' && matchEvent['own-goal'] === 'true') {
        ret = ret + ' (' + matchStateMethods.translate('own-goal-abbr') + ')';
      }
      return ret;
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
    var score = MatchTimelineConstants.timelineEl.data('match-score').split(':');
    return parseInt(score[0]) === parseInt(score[1]);
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

  countPenaltyShootOutGoalsAndAttemptsOnly: function(allMatchEvents) {
    var score    = "0:0";
    var attempts = "0:0";
    var finalWhistleCount = 0;
    $.each(allMatchEvents, function(index, matchEvent) {
      if (matchEvent.type === 'final-whistle') {
        finalWhistleCount++;
      } else if (finalWhistleCount >= 2) {
        if (matchStateMethods.isGoalEvent(matchEvent) === true) {
          score = matchStateMethods.addGoalToScore(matchEvent, score);
        }
        attempts = matchStateMethods.addGoalToScore(matchEvent, attempts);
      }
    });
    return {score: score, attempts: attempts};
  },

  isPenaltyShootOutOver: function(allMatchEvents) {
    var ret = false;
    var firstXAttempts = 5;
    var indexes = matchStateMethods.finalEventIndexes(allMatchEvents);
    if (indexes.finalWhistleIndexes.length === 3) {
      ret = true;
    } else if (matchStateMethods.isPenaltyShootOut(allMatchEvents) === true) {
      var goalsAndAttempts = matchStateMethods.countPenaltyShootOutGoalsAndAttemptsOnly(allMatchEvents);
      var goals    = _.map(goalsAndAttempts['score'].split(':'), function(number){return parseInt(number);});
      var attempts = _.map(goalsAndAttempts['attempts'].split(':'), function(number){return parseInt(number);});
      ret = 
        _.all(attempts, function(el) {return el >= firstXAttempts;}) === true && 
        _.uniq(attempts).length === 1 && 
        _.uniq(goals).length > 1;
      if (ret === false) {
        var minimumGoals      = _.min(goals);
        var minimumGoalsIndex = _.findIndex(goals, function(goals){ return goals === minimumGoals; });
        var maximumGoals      = _.max(goals);
        var maximumGoalsIndex = Math.abs(minimumGoalsIndex - 1);
        ret = maximumGoals - minimumGoals > firstXAttempts - attempts[minimumGoalsIndex];
      }
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
    MatchTimelineConstants.timelineEl.data('match-score', score);
    return score;
  },

  matchScore: function() {
    return MatchTimelineConstants.timelineEl.data('match-score');
  },

  isGoalEvent: function(matchEvent) {
    return ['goal', 'penalty', 'penalty-goal'].indexOf(matchEvent.type) > -1;
  },

  addGoalToScore: function(matchEvent, score) {
    score = score.split(':');
    var scorePositions = ['left', 'right'];
    var scoreIndex = null;
    if (matchEvent['own-goal'] === 'true') {
      scoreIndex = _.findIndex(scorePositions, function(el) { return el !== matchEvent.position; });
    } else {
      scoreIndex = _.findIndex(scorePositions, function(el) { return el === matchEvent.position; });
    }
    score[scoreIndex] = parseInt(score[scoreIndex]) + 1;
    return score.join(':');
  },

  countMatchScore: function(matchEvent) {
    var score = matchStateMethods.matchScore();
    if (matchStateMethods.isGoalEvent(matchEvent) === true) {
      score = matchStateMethods.addGoalToScore(matchEvent, score);
      MatchTimelineConstants.timelineEl.data('match-score', score);
    }
    return score;
  },

  finalWhistleTextAddition: function(allMatchEvents) {
    var ret = '';
    if (matchStateMethods.isPenaltyShootOut(allMatchEvents) === true) {
      ret = " (" + matchStateMethods.translate("after-penalty-shoot-out-abbr") + ")";
    } else if (matchStateMethods.halfTimeNumber(allMatchEvents) === 4) {
      ret = " (" + matchStateMethods.translate("after-extra-time-abbr") + ")";
    }
    return ret;
  }
};

export default matchStateMethods;
