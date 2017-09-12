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
      $('.js-payment-list[data-payment-list-id='+payload.payment_list_id+'] .js-sum').text(payload.sum);
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

    });
  }
};

export default PaymentListUpdates;
