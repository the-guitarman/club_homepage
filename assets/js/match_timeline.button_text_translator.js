import matchStateMethods from "./match_timeline.match_state_methods";

let buttonTextTranslator = {
  buttonSelector: '.js-match-event-buttons button',

  noTransations: ['foul-yellow', 'foul-yellow-red', 'foul-red'],

  specials: {
    break: matchStateMethods.breakEventButtonTranslation()
  },

  init: () => {
    $.each($(buttonTextTranslator.buttonSelector), function(index, button) {
      button = $(button);
      var matchEvent = button.data('match-event');
      if (buttonTextTranslator.noTransations.indexOf(matchEvent) === -1) {
        var translation = buttonTextTranslator.specials[matchEvent];
        if (_.isEmpty(translation) === true) {
          translation = matchStateMethods.translate(matchEvent);
        }
        if (!_.isEmpty(translation)) {
          var subElement = button.find('img, span');
          if (subElement.length > 0) {
            button.attr('title', translation);
          } else {
            button.html(translation);
          }
        }
      }
    });
  }
  
};

export default buttonTextTranslator;
