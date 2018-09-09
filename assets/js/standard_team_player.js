let StandardTeamPlayerUpdates = {
  init(socket, teamId) {
    if (_.isEmpty(teamId)) {
      return;
    }

    socket.connect();
    let channel = socket.channel("standard-team-players:" + teamId);
    // channel.onError(e => console.log("something went wrong", e));
    // channel.onClose(e => console.log("channel closed", e));

    channel.join()
      // .receive("ok", resp => { console.log("Joined successfully", resp); })
      // .receive("error", resp => { console.log("Unable to join", resp); })
    ;

    let toggleState = (userId, standard_shirt_number, state) => {
      let tr = $('.js-standard-team-players tr[data-player-id="' + userId + '"]');
      tr.find('input[type="checkbox"][value="' + userId + '"]').prop('checked', state);
      tr.find('input[type="number"]').val(standard_shirt_number);
    };

    let showErrors = (userId, reply) => {
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
    };

    let highlightTableRow = (userId, color) => {
      $('.js-standard-team-players tr[data-player-id="' + userId + '"]').effect("highlight", {color: color}, 1000);
    };

    $('.js-standard-team-players button').on('click', function(event, state) {
      let tr = $(this).closest("tr");
      let userId = tr.data("player-id");
      let memberCheckbox = tr.find('input[name="user_id"]');
      let standard_shirt_number = tr.find('input[name="standard_shirt_number"]').val();

      // console.log(this); // DOM element
      // console.log(event); // jQuery event
      // console.log(state); // true | false

      tr
        .find('.form-group')
          .removeClass('has-error')
          .removeClass('has-error')
          .removeClass('has-error')
        .find('.help-block')
          .addClass('hidden')
          .text('');

      let action = "remove";
      if (memberCheckbox.prop('checked')) {
        action = "add_or_update";
      }

      channel
        .push("player:" + action, {user_id: userId, standard_shirt_number: standard_shirt_number})
        .receive("ok", function(reply) {
          toggleState(userId, reply.standard_shirt_number, true);
          highlightTableRow(userId, '#dff0d8');
        })
        .receive("error", (reply) => {
          toggleState(userId, standard_shirt_number, !!state);
          highlightTableRow(userId, '#f2dede');
          showErrors(userId, reply);
        })
        .receive("ignore", () => {
          //console.log("auth error")
          toggleState(userId, standard_shirt_number, !!state);
        })
        .receive("timeout", () => {
          //console.log("connection interruption")
          toggleState(userId, standard_shirt_number, !!state);
        });
    });

    channel.on("player:added_or_updated", payload => {
      toggleState(payload.user_id, payload.standard_shirt_number, true);
    });

    channel.on("player:removed", payload => {
      toggleState(payload.user_id, payload.standard_shirt_number, false);
    });

  }
};

export default StandardTeamPlayerUpdates;
