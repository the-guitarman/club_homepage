import matchStateMethods from "./match_timeline.match_state_methods";

let formTextTranslator = {
  init: () => {
    var labels = $('.js-match-event-form label');
    $.each(labels, function(index, label) {
      label = $(label);
      var translation = matchStateMethods.translate(label.attr('for'));
      if (!_.isEmpty(translation)) {
        label.text(translation);
      }
    });
  }
};

export default formTextTranslator;
