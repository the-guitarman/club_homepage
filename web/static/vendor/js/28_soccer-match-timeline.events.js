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
    });
});
