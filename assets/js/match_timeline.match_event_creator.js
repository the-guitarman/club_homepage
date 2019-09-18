import matchStateMethods from './match_timeline.match_state_methods';
//let matchStateMethods = require('./match_timeline.match_state_methods');

let matchEventCreator = {
  minute: function(matchEvent) {
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
  },

  concatText: function(text1, text2, matchEventType) {
    var ret = text1 + ' ' + text2;
    if (['goal', 'penalty', 'replacement', 'penalty-goal', 'no-penalty-goal'].indexOf(matchEventType) > -1) {
      ret = text1 + ', ' + text2;
    }
    return ret;
  },

  contentAlignment: function(html, matchEvent) {
    if (matchEvent.position === 'left') {
      if (matchEvent.text.trim() != '') {
        html = matchEventCreator.concatText(matchEvent.text, html, matchEvent.type);
      }
    } else if (matchEvent.position === 'right') {
      if (matchEvent.text.trim() != '') {
        html = matchEventCreator.concatText(html, matchEvent.text, matchEvent.type);
      }
    } else {
      html = '<strong>' + matchEvent.event + '</strong><br />' + matchEvent.text;
    }
    return html;
  },

  foulHTML: function(matchEventType) {
    var ret = '';
    if (matchEventType === 'foul-yellow') {
      ret = '<span class="foul-card yellow"></span>';
    } else if (matchEventType === 'foul-red') {
      ret = '<span class="foul-card red"></span>';
    } else if (matchEventType === 'foul-yellow-red') {
      ret = matchEventCreator.foulHTML('foul-yellow') + matchEventCreator.foulHTML('foul-red');
    }
    return ret;
  },

  content: function(matchEvent) {
    var html = '<p>';
    var imagePath = 'images/timeline/';
    if (!_.isEmpty(window.location.hostname)) {
      imagePath = '/' + imagePath;
    }
    if (['goal', 'penalty', 'penalty-goal', 'no-penalty-goal'].indexOf(matchEvent.type) > -1) {
      var soccerBallImage = '';
      if (matchEvent.type === 'penalty-goal') {
        soccerBallImage = '<img src="' + imagePath + 'soccer_ball_green_24x24.png" alt="" />';
      } else if (matchEvent.type === 'no-penalty-goal') {
        soccerBallImage = '<img src="' + imagePath + 'soccer_ball_red_24x24.png" alt="" />';
      } else {
        soccerBallImage = '<img src="' + imagePath + 'soccer_ball_24x24.png" alt="" />';
      }
      var text = soccerBallImage + ' ' + matchEvent.typeTranslation;
      if (matchEvent.position === 'left') {
        text = matchEvent.typeTranslation + ' ' + soccerBallImage;
      }
      html = html + matchEventCreator.contentAlignment(text, matchEvent);
    } else if (matchEvent.type === 'replacement') {
      var image = '<img src="' + imagePath + 'replacement_24x24.png" class="replacement" alt="" />';
      var text = image + ' ' + matchEvent.typeTranslation;
      if (matchEvent.position === 'left') {
        text = matchEvent.typeTranslation + ' ' + image;
      }
      matchEvent.text = matchEvent['text-in'] + ' for ' + matchEvent['text-out'];
      html = html + matchEventCreator.contentAlignment(text, matchEvent);
    } else if (_.contains(['foul-yellow', 'foul-yellow-red', 'foul-red'], matchEvent.type)) {
      html = html + matchEventCreator.contentAlignment(matchEventCreator.foulHTML(matchEvent.type), matchEvent);
    } else {
      html = html + '<strong>' + matchEvent.event + '</strong><br />' + matchEvent.text;
    }
    return html + '</p>';
  },

  contentCt: function(matchEvent) {
    var html = '';
    if (matchEvent.type != "timeline+minute") {
      html = '<div class="timeline-content">' + matchEventCreator.content(matchEvent) + '</div>';
    } else {
      matchEvent.position = 'top';
      html = '<div class="timeline-content">' + matchStateMethods.translate('match-score') + ': ' + matchStateMethods.matchScore() + '</div>';
    }
    return html;
  },

  point: function(matchEvent) {
    var html = '<div class="timeline-state position-' + matchEvent.position + '">';
    if (matchEvent.eventIndex >= matchEvent.lastEventIndex && $('.js-match-event-buttons button').length > 0) {
      html = html +
        '<div class="css-close-button-wrap text-right">' + 
          '<button type="button" class="close" aria-label="Close" data-event-index="' + matchEvent.eventIndex + '" title="' + matchStateMethods.translate('delete-latest-element') + '">' + 
            '<span aria-hidden="true">&times;</span>' +
          '</button>' +
        '</div>';
    }
    if (matchEvent.position === 'bottom') {
      html = html + matchEventCreator.minute(matchEvent) + matchEventCreator.contentCt(matchEvent);
    } else {
      html = html + matchEventCreator.contentCt(matchEvent) + matchEventCreator.minute(matchEvent);
    }
    return html + '</div>';
  },

  timeline: function(matchEvent) {
    var ret = '';
    if (matchEvent.eventHeight > 0) {
      ret = '<div style="height: ' + matchEvent.eventHeight + 'px;"></div>';
    }
    return ret;
  },

  init: function(matchEvent) {
    if (matchEvent.type === 'timeline') {
      return matchEventCreator.timeline(matchEvent);
    } else if (matchEvent.type === 'timeline+minute') {
      return matchEventCreator.point(matchEvent) + matchEventCreator.timeline(matchEvent);
    } else {
      return matchEventCreator.point(matchEvent);
    }
  }
};

export default matchEventCreator;
