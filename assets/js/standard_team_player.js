let StandardTeamPlayerUpdates = {
  socket: null,
  teamId: 0,
  channel: null,

  toggleState: (userId, standard_shirt_number, state) => {
    let tr = $('.js-standard-team-players tr[data-player-id="' + userId + '"]');
    tr.find('input[type="checkbox"][value="' + userId + '"]').prop('checked', state);
    tr.find('input[type="number"]').val(standard_shirt_number);
  },

  showErrors: (userId, reply) => {
    if (!_.isEmpty(reply.errors)) {
      let tr = $('.js-standard-team-players tr[data-player-id="' + userId + '"]');

      $.each(reply.errors, function(fieldName, errorMsg) {
        tr
          .find('input[name="' + fieldName + '"]')
          .closest('.form-group')
          .addClass('has-error')
          .find('.help-block')
          .removeClass('hidden')
          .text(errorMsg)
        ;
      });
    }
  },

  connectAndJoin: () => {
    StandardTeamPlayerUpdates.socket.connect();
    StandardTeamPlayerUpdates.channel = StandardTeamPlayerUpdates.socket.channel("standard-team-players:" + StandardTeamPlayerUpdates.teamId);

    StandardTeamPlayerUpdates.channel
      .join()
    // .onError(e => console.log("something went wrong", e))
    // .onClose(e => console.log("channel closed", e))
    // .receive("ok", resp => { console.log("Joined successfully", resp); })
    // .receive("error", resp => { console.log("Unable to join", resp); })
    ;
  },

  highlightTableRow: (userId, color) => {
    $('.js-standard-team-players tr[data-player-id="' + userId + '"]').effect("highlight", {color: color}, 1000);
  },

  canInit: () => {
    return _.isNumber(StandardTeamPlayerUpdates.teamId) && StandardTeamPlayerUpdates.teamId > 0;
  },

  init: (socket) => {
    StandardTeamPlayerUpdates.socket = socket;
    StandardTeamPlayerUpdates.teamId = parseInt($('.js-team-page.js-standard-team-players').data('team-id'));

    if (StandardTeamPlayerUpdates.canInit()) {
      console.log('StandardTeamPlayerUpdates', '-1-');
      StandardTeamPlayerUpdates.connectAndJoin();
      StandardTeamPlayerUpdates.initUIEvents();
      StandardTeamPlayerUpdates.initChannelEvents();
    }
  },

  getTableRow: (jQueryEl) => {
    return $(jQueryEl).closest("tr");
  },

  resetForm: (jQueryEl) => {
    StandardTeamPlayerUpdates.getTableRow(jQueryEl)
      .find('.form-group')
      .removeClass('has-error')
      .removeClass('has-error')
      .removeClass('has-error')
      .find('.help-block')
      .addClass('hidden')
      .text('');
  },

  getChannelAction: (jQueryEl) => {
    let memberCheckbox = StandardTeamPlayerUpdates
      .getTableRow(jQueryEl)
      .find('input[name="user_id"]');
    let action = "remove";
    if (memberCheckbox.prop('checked')) {
      action = "add_or_update";
    }
    return action;
  },

  initUIEvents: () => {
    $('.js-standard-team-players button').on('click', function(event, state) {
      let tr = StandardTeamPlayerUpdates.getTableRow($(this));
      let userId = tr.data("player-id");
      let standard_shirt_number = tr.find('input[name="standard_shirt_number"]').val();
      StandardTeamPlayerUpdates.resetForm($(this));
      let action = StandardTeamPlayerUpdates.getChannelAction($(this));

      StandardTeamPlayerUpdates.channel
        .push("player:" + action, {user_id: userId, standard_shirt_number: standard_shirt_number})
        .receive("ok", function(reply) {
          StandardTeamPlayerUpdates.toggleState(userId, reply.standard_shirt_number, true);
          StandardTeamPlayerUpdates.highlightTableRow(userId, '#dff0d8');
        })
        .receive("error", (reply) => {
          StandardTeamPlayerUpdates.toggleState(userId, standard_shirt_number, !!state);
          StandardTeamPlayerUpdates.highlightTableRow(userId, '#f2dede');
          StandardTeamPlayerUpdates.showErrors(userId, reply);
        })
        .receive("ignore", () => {
          StandardTeamPlayerUpdates.toggleState(userId, standard_shirt_number, !!state);
        })
        .receive("timeout", () => {
          StandardTeamPlayerUpdates.toggleState(userId, standard_shirt_number, !!state);
        });
    });
  },

  initChannelEvents: () => {
    StandardTeamPlayerUpdates.channel.on("player:added_or_updated", function(payload) {
      StandardTeamPlayerUpdates.toggleState(payload.user_id, payload.standard_shirt_number, true);
    });

    StandardTeamPlayerUpdates.channel.on("player:removed", function(payload) {
      StandardTeamPlayerUpdates.toggleState(payload.user_id, payload.standard_shirt_number, false);
    });
  }
};

export default StandardTeamPlayerUpdates;
