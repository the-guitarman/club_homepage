let PaymentListUpdates = {
  init(socket, paymentListId) {
    if (_.isEmpty(paymentListId) && !_.isNumber(paymentListId)) {
      return;
    }

    socket.connect();
    let channel = socket.channel("payment-lists:" + paymentListId);
    channel.onError(e => console.log("something went wrong", e));
    channel.onClose(e => console.log("channel closed", e));

    channel.join()
      .receive("ok", resp => { console.log("Joined successfully", resp); })
      .receive("error", resp => { console.log("Unable to join", resp); });

    let processReply = function(reply) {
      var debitorRow = $('.js-payment-list[data-payment-list-id='+reply.payment_list_id+'] .js-payment-list-debitor[data-payment-list-debitor-id='+reply.debitor_id+']');
      debitorRow.find('.js-sum').text(reply.sum);
      debitorRow.find('input').val(reply.number_of_units);
    };

    channel.on("number_of_units:updated", payload => {
      var selector = 'a.js-payment-list-debitor[data-payment-list-debitor-id=' + payload.debitor_id + '] .badge.background-red';

      $('.popover ' + selector).text(payload.sum);

      $('a[data-toggle="popover"]').each(function(index) {
        var self = $(this);
        console.log(self);
        var popoverContent = self.data('content');
        popoverContent = $('<div></div>').append(popoverContent);
        popoverContent.find(selector).text(payload.sum);
        self.attr('data-content', popoverContent.html())
      });
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
        channel
          .push("number_of_units:apply_delta", {payment_list_id: paymentListId, debitor_id: debitorId, number_of_units_delta: deltaValue(self, $(this))})
          .receive("ok", function(reply) {
            processReply(reply);
          });
      });

      self.find('a.js-payment-list-debitor-reset').click(function() {
        var result = confirm($(this).attr('data-confirm'));
        if (result) {
          channel
            .push("number_of_units:reset", {payment_list_id: paymentListId, debitor_id: debitorId, number_of_units: 0})
            .receive("ok", function(reply) {
              processReply(reply);
            });

        }
        return false;
      });
    });
  }
};

export default PaymentListUpdates;
