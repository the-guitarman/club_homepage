$(document).ready(function() {
  $(document)
  /*
    .on('click', '.flat-checkbox label', function() {
    	$(this).toggleClass('checked');
    	var checkbox = $(this).parent().find('input');
    	if (checkbox.prop('checked') === 'checked' || checkbox.attr('checked') === 'checked') {
    		checkbox.removeProp('checked').removeAttr('checked');
    	} else {
    		checkbox.prop('checked', 'checked').attr('checked', 'checked');
    	}
    })
  */
    .on('match-event:afterAdd', '#match-timeline', function(event, matchEvent, matchEvents) {
      matchEventButtonHandler.switchButtons();
      matchEventButtonHandler.hideEventForm();
    })
    .on('match-event:afterRemove', '#match-timeline', function(event, removedElementIndex, removedElement, matchEvents) {
      matchEventButtonHandler.switchButtons();
      matchEventButtonHandler.hideEventForm();
    })
    .on('match-event:show-event-form', '#match-timeline', function(event) {
      var matchEventFormEl = $('.js-match-event-form');
      var position = matchEventFormEl.find('input[name=position]').val();
      var inputGroupButtons = matchEventFormEl.find('.input-group-btn');
      inputGroupButtons.addClass('hidden');
      inputGroupButtons.filter('.' + position).removeClass('hidden');
    });
});
