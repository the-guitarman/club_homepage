let PaymentListUpdates = {
  jsPaymentListSelector: '.js-payment-list', 
  jsPaymentListDebitorSelector: '.js-payment-list-debitor', 
  channels: {}, 

  getPaymentListId: (jQueryEl) => {
    return $(jQueryEl)
      .closest(PaymentListUpdates.jsPaymentListSelector)
      .data('payment-list-id');
  },

  getPaymentListDebitorId: (jQueryEl) => {
    return $(jQueryEl)
      .closest(PaymentListUpdates.jsPaymentListDebitorSelector)
      .data('payment-list-debitor-id');
  },

  addChannel: (paymentListId, channel) => {
    PaymentListUpdates.channels[paymentListId] = channel;
  },

  getChannel: (paymantListId) => {
    return PaymentListUpdates.channels[paymantListId];
  },

  connectAndJoin: (paymentListId, socket) => {
    if (_.isEmpty(paymentListId) && !_.isNumber(paymentListId)) {
      return;
    }

    let channel = socket.channel("payment-lists:" + paymentListId);

    channel.onError((e) => console.log("something went wrong", e));
    channel.onClose((e) => console.log("channel closed", e));

    channel.join()
      .receive("ok", (resp) => { console.log("Joined successfully", resp); })
      .receive("error", (resp) => { console.log("Unable to join", resp); });

    channel.on("number_of_units:updated", payload => {
      var selector = 'a' + PaymentListUpdates.jsPaymentListDebitorSelector + '[data-payment-list-debitor-id=' + payload.debitor_id + '] .badge.background-red';

      $('.popover ' + selector).text(payload.sum);

      $('a[data-toggle="popover"]').each(function(index) {
        var self = $(this);
        var popoverContent = self.data('content');
        popoverContent = $('<div></div>').append(popoverContent);
        popoverContent.find(selector).text(payload.sum);
        self.attr('data-content', popoverContent.html())
      });
    });

    PaymentListUpdates.addChannel(paymentListId, channel);
  },

  processReply: function(reply) {
    var debitorRow = $(PaymentListUpdates.jsPaymentListSelector + '[data-payment-list-id='+reply.payment_list_id+'] ' + PaymentListUpdates.jsPaymentListDebitorSelector + '[data-payment-list-debitor-id='+reply.debitor_id+']');
    debitorRow.find('.js-sum').text(reply.sum);
    debitorRow.find('input').val(reply.number_of_units);
  },

  deltaValue: (numberField, button) => {
    var buttonEl = $(button);
    var step = $(numberField).find('input[name="payment_list_debitor[number_of_units]"]').attr('step');
    step = parseInt(step);
    if (buttonEl.find('.glyphicon.glyphicon-minus').length > 0) {
      step = -1 * step;
    }
    return step;
  },

  initUIEvents: () => {
    $(document).on('click', PaymentListUpdates.jsPaymentListDebitorSelector + ' a.js-payment-list-debitor-reset', function(e) {
      e.preventDefault();
      e.stopPropagation();

      let clickedEl = $(this);
      let result = confirm(clickedEl.attr('data-confirmation'));
      if (result) {
        let paymentListId = PaymentListUpdates.getPaymentListId(clickedEl);
        let debitorId = PaymentListUpdates.getPaymentListDebitorId(clickedEl);
        let channel = PaymentListUpdates.getChannel(paymentListId);

        channel
          .push("number_of_units:reset", {payment_list_id: paymentListId, debitor_id: debitorId, number_of_units: 0})
          .receive("ok", function(reply) {
            PaymentListUpdates.processReply(reply);
          });
      }

      return false;
    });

    $(document).on('click', PaymentListUpdates.jsPaymentListDebitorSelector + ' .js-number-field .input-group-addon', function(e) {
      e.preventDefault();
      e.stopPropagation();

      let clickedEl = $(this);
      let paymentListDebitor = clickedEl.closest(PaymentListUpdates.jsPaymentListDebitorSelector);
      let paymentListId = PaymentListUpdates.getPaymentListId(clickedEl);
      let debitorId = PaymentListUpdates.getPaymentListDebitorId(clickedEl);
      let channel = PaymentListUpdates.getChannel(paymentListId);

      channel
        .push("number_of_units:apply_delta", {payment_list_id: paymentListId, debitor_id: debitorId, number_of_units_delta: PaymentListUpdates.deltaValue(paymentListDebitor, clickedEl)})
        .receive("ok", function(reply) {
          PaymentListUpdates.processReply(reply);
        });

      return false;
    });
    
  },


  init: (socket) => {
    socket.connect();

    $(PaymentListUpdates.jsPaymentListSelector).each(function(){
      PaymentListUpdates.connectAndJoin($(this).data('payment-list-id'), socket);
    });

    // $('[data-toggle=popover]').each(function(){
    //   var content = $(this).data('content');
    //   var paymentLists = $(content).find('.js-payment-list');
    //   paymentLists.each(function(){
    //     var paymentListId = $(this).data('payment-list-id');
    //     PaymentListUpdates.init(socket, paymentListId);
    //   });
    // });

    PaymentListUpdates.initUIEvents();
  }
};

export default PaymentListUpdates;
