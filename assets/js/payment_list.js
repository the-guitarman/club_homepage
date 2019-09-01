let PaymentListUpdates = {
  init(socket) {
    let channels = {};

    let jsPaymentListSelector = '.js-payment-list';
    let getPaymentListId = (jQueryEl) => {
      return $(jQueryEl)
        .closest(jsPaymentListSelector)
        .data('payment-list-id');
    };

    let jsPaymentListDebitorSelector = '.js-payment-list-debitor';
    let getPaymentListDebitorId = (jQueryEl) => {
      return $(jQueryEl)
        .closest(jsPaymentListDebitorSelector)
        .data('payment-list-debitor-id');
    };

    let connectAndJoin = (paymentListId) => {
      if (_.isEmpty(paymentListId) && !_.isNumber(paymentListId)) {
        return;
      }

      socket.connect();

      let channel = socket.channel("payment-lists:" + paymentListId);
      
      channel.onError((e) => console.log("something went wrong", e));
      channel.onClose((e) => console.log("channel closed", e));

      channel.join()
        .receive("ok", (resp) => { console.log("Joined successfully", resp); })
        .receive("error", (resp) => { console.log("Unable to join", resp); });

      channel.on("number_of_units:updated", payload => {
        var selector = 'a' + jsPaymentListDebitorSelector + '[data-payment-list-debitor-id=' + payload.debitor_id + '] .badge.background-red';

        $('.popover ' + selector).text(payload.sum);

        $('a[data-toggle="popover"]').each(function(index) {
          var self = $(this);
          var popoverContent = self.data('content');
          popoverContent = $('<div></div>').append(popoverContent);
          popoverContent.find(selector).text(payload.sum);
          self.attr('data-content', popoverContent.html())
        });
      });

      channels[paymentListId] = channel;
    };

    $(jsPaymentListSelector).each(function(){
      connectAndJoin($(this).data('payment-list-id'));
    });

    // $('[data-toggle=popover]').each(function(){
    //   var content = $(this).data('content');
    //   var paymentLists = $(content).find('.js-payment-list');
    //   paymentLists.each(function(){
    //     var paymentListId = $(this).data('payment-list-id');
    //     PaymentListUpdates.init(socket, paymentListId);
    //   });
    // });

    let processReply = function(reply) {
      var debitorRow = $(jsPaymentListSelector + '[data-payment-list-id='+reply.payment_list_id+'] ' + jsPaymentListDebitorSelector + '[data-payment-list-debitor-id='+reply.debitor_id+']');
      debitorRow.find('.js-sum').text(reply.sum);
      debitorRow.find('input').val(reply.number_of_units);
    };

    let deltaValue = (numberField, button) => {
      var buttonEl = $(button);
      var step = $(numberField).find('input[name="payment_list_debitor[number_of_units]"]').attr('step');
      step = parseInt(step);
      if (buttonEl.find('.glyphicon.glyphicon-minus').length > 0) {
        step = -1 * step;
      }
      return step;
    };


    $(document).on('click', jsPaymentListDebitorSelector + ' a.js-payment-list-debitor-reset', function(e) {
      e.preventDefault();
      e.stopPropagation();

      let result = confirm($(this).attr('data-confirm'));
      if (result) {
        let self = $(this);
        let paymentListId = getPaymentListId(self);
        let debitorId = getPaymentListDebitorId(self);
        channels[paymentListId]
          .push("number_of_units:reset", {payment_list_id: paymentListId, debitor_id: debitorId, number_of_units: 0})
          .receive("ok", function(reply) {
            processReply(reply);
          });
      }
      return false;
    });

    $(document).on('click', jsPaymentListDebitorSelector + ' .js-number-field .input-group-addon', function(e) {
      e.preventDefault();
      e.stopPropagation();

      let self = $(this);
      let paymentListDebitor = self.closest(jsPaymentListDebitorSelector);
      let paymentListId = getPaymentListId(self);
      let debitorId = getPaymentListDebitorId(self);

      channels[paymentListId]
        .push("number_of_units:apply_delta", {payment_list_id: paymentListId, debitor_id: debitorId, number_of_units_delta: deltaValue(paymentListDebitor, self)})
        .receive("ok", function(reply) {
          processReply(reply);
        });
      return false;
    });
  }
};

export default PaymentListUpdates;
