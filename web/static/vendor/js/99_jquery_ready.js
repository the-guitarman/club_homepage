$(document).ready(function(){
  $('.input-group.date').datepicker({
      autoclose: true,
      format: "dd.mm.yyyy",
      language: "de",
      startView: 2,
      weekStart: 1
  });
});