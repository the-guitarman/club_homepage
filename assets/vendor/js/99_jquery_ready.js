$(document).ready(function() {
  /*
  $('.form-group.new-record-element').each(function() {
    var self = $(this);
    var inputElement = self.find('input[type="text"], input[type="password"], select, textarea');
    $('<span class="input-group-addon"><i class="glyphicon glyphicon-plus"></i></span>').insertAfter(inputElement);
    var innerHtml = self.html();
    var div = $('<div class="input-group"></div>');
    div.html(innerHtml);
    self.html(div);
  });

  $(document).on('click', '.new-record-element .input-group-addon', function(e) {
    var self = $(this);
    var form = self.closest('form');
    var fields = _.filter(form.serializeArray(), function(field){ return !(field.name[0] === '_'); });
    window.location.href = self.closest('.new-record-element').data('href') + '?backData=' + encodeURI(JSON.stringify(fields)) + 'backURL=' + encodeURI(window.location.href);
    e.preventDefault();
    return false;
  });

  $('.content-container form').each(function() {
    var self = $(this);
    self.prop('action', self.prop('action') + window.location.search);
  });
  */


  $('[data-toggle="popover"]').popover();
  $('[data-toggle="tooltip"]').tooltip();

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

  var i18n = $('body').data('localization');
  var dateFieldAttributes = {
    format: (i18n['date_format'] || 'YYYY-MM-DD'),
    inline: false,
    locale: (i18n['locale'] || 'en'),
    showClose: true,
    sideBySide: false,
    tooltips: {
      today: i18n['today'],
      clear: i18n['clear_selection'],
      close: i18n['close'],
      selectMonth: i18n['select_month'],
      prevMonth: i18n['previous_month'],
      nextMonth: i18n['next_month'],
      selectYear: i18n['select_year'],
      prevYear: i18n['previous_year'],
      nextYear: i18n['next_year'],
      selectDecade: i18n['select_decade'],
      prevDecade: i18n['previous_decade'],
      nextDecade: i18n['next_decade'],
      prevCentury: i18n['previous_century'],
      nextCentury: i18n['next_century'],
      selectTime: i18n['select_time']
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

  $(document).on('click', '.input-group-addon.btn', function(e) {
    e.preventDefault();
    var self = $(this);
    var input = self.parent().find('input');
    var value = parseInt(input.val());

    var step = input.attr('step');
    if (_.isEmpty(step)) { step = 1; }

    var operationEl = self.find('.glyphicon');
    var operation = (operationEl.hasClass('glyphicon-minus') ? -1 : 1) * step;

    value = value + operation;

    var min = input.attr('min');
    if (!_.isEmpty(min) && value < min) { value = min; }

    var max = input.attr('max');
    if (!_.isEmpty(max) && value > max) { value = max; }

    input.val(value);
  });
});
