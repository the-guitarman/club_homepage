$(document).on('click', '.js-system-of-play-buttons button', function() {
  var button = $(this);
  button.parent().find('button').removeClass('active');
  button.addClass('active');

  $('.css-match-ground').addClass('hidden').filter('.' + button.html()).removeClass('hidden');
});
