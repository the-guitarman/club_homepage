$(document).ready(function() {
  $(document).on('click', '.js-match-event-form .input-group-btn .dropdown-menu a', function() {
    var self = $(this);
    self.closest('.input-group').find('input').val(self.text());
  });
});
