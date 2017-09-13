let PaymentListUpdates = {
  init(socket, paymentListId) {
    if (_.isNaN(paymentListId)) {
      return;
    }

    socket.connect();
    let channel = socket.channel("payment-lists:" + paymentListId);
    channel.onError(e => console.log("something went wrong", e));
    channel.onClose(e => console.log("channel closed", e));

    channel.join()
      .receive("ok", resp => { console.log("Joined successfully", resp); })
      .receive("error", resp => { console.log("Unable to join", resp); });

    channel.on("apply_delta_value", payload => {
      var debitorRow = $('.js-payment-list[data-payment-list-id='+payload.payment_list_id+'] .js-payment-list-debitor[data-payment-list-debitor-id='+payload.debitor_id+']');
      debitorRow.find('.js-sum').text(payload.sum);
      debitorRow.find('input').val(payload.number_of_units);
    });

    let deltaValue = (numberField, button) => {
      var buttonEl = $(button);
      var step = $(numberField).find('input[name="payment_list_debitor[number_of_units]"]').attr('step');
      step = parseInt(step);
      if (buttonEl.find('.glyphicon.glyphicon-minus').length > 0) {
        step = -1 * step;
      }
      return step;
    };

    $('.js-payment-list-debitor').each(function(index) {
      var self = $(this);
      var debitorId = self.data('payment-list-debitor-id');

      self.find('.js-number-field .input-group-addon').click(function() {
        channel.push("apply_delta_value", {payment_list_id: paymentListId, debitor_id: debitorId, number_of_units_delta: deltaValue(self, $(this))});
      });

      self.find('a.js-payment-list-debitor-reset').click(function() {
        var result = confirm($(this).attr('data-confirm'));
        if (result) {
          channel.push("reset_value", {payment_list_id: paymentListId, debitor_id: debitorId, number_of_units: 0});

        }
        return false;
      });
    });
  }
};

export default PaymentListUpdates;
