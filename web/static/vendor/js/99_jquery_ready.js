$(document).ready(function() {
  $(document).on('deviceready', function() {
    $('.js-show-on-mobile-device').removeClass('hidden');
  });

  $(".js-home-match input[type=radio]").prop('checked', false);

  if (typeof(MediumEditor) != 'undefined') {
    var editor = new MediumEditor('.js-medium-editor', {
      toolbar: {
        buttons: ['bold', 'italic', 'underline', 'anchor', 'h2', 'h3', 'image']
      }
    });
  }
  /*
  $('.input-group.date').datepicker({
      autoclose: true,
      format: "dd.mm.yyyy",
      language: "de",
      startView: 2,
      weekStart: 1
  });
  */

  var dateFieldAttributes = {
    format: 'DD.MM.YYYY',
    inline: false,
    locale: 'de',
    showClose: true,
    sideBySide: false,
    tooltips: {
      today: 'Heute ',
      clear: 'Auswahl zurücksetzen',
      close: 'Schließen',
      selectMonth: 'Monat auswählen',
      prevMonth: 'Vorheriger Monat',
      nextMonth: 'Nächster Monat',
      selectYear: 'Jahr auswählen',
      prevYear: 'Vorheriges Jahr',
      nextYear: 'Nächstes Jahr',
      selectDecade: 'Dekade auswählen',
      prevDecade: 'Vorherige Dekade',
      nextDecade: 'Nächste Dekade',
      prevCentury: 'Vorheriges Jahrhundert',
      nextCentury: 'Nächstes Jahrhundert',
      selectTime: 'Datum/Zeit einstellen'
    },
    widgetPositioning: {horizontal: 'left'},
    viewMode: 'years'
  };

  $('.input-group.date, .input-group.datetime').each(function() {
    var self = $(this);
    var format = self.find('input').data('format');
    var attributes = $.extend({}, dateFieldAttributes);
    if (format) {
      attributes['format'] = format;
    }
    self.datetimepicker(attributes);
  });

  $('.input-group.date input, .input-group.datetime input').click(function(e){
    $(this).parent().find('.input-group-addon').trigger('click');
  });

  $('select').select2({
    //tags: "true",
    placeholder: "",
    allowClear: true
  }).on("change", function(e) {
    //console.log(e);
  });

  $("input[type=radio][checked=checked]").prop('checked', true);
  $("input[type=radio], input[type=checkbox]").bootstrapSwitch();

  $(document).on('click', '.alert .close', function(e){
    e.preventDefault();
    $(this).parents('.alert').slideUp('slow', function(){
      $(this).remove();
    });
    return false;
  });
});
