let MatchCommitmentUpdates = {
  init(socket, userId) {
    if (_.isNaN(userId)) {
      return;
    }

    socket.connect();
    let channel = socket.channel("match-commitments:" + userId);
    // channel.onError(e => console.log("something went wrong", e));
    // channel.onClose(e => console.log("channel closed", e));

    channel.join()
      // .receive("ok", resp => { console.log("Joined successfully", resp); })
      // .receive("error", resp => { console.log("Unable to join", resp); })
    ;

    let toggleState = (userId, state) => {
      $('.js-standard-team-players input[type="checkbox"][value="' + userId + '"]').toggleState(state, true);
    };

    $('.js-standard-team-players input[type="checkbox"]').on('switchChange.bootstrapSwitch', function(event, state) {
      let self = $(this);
      let userId = self.val();

      // console.log(this); // DOM element
      // console.log(event); // jQuery event
      // console.log(state); // true | false

      let action = "remove";
      if (state) {
        action = "add";
      }
      channel
        .push("player:" + action, {user_id: userId})
        .receive("ok", function(reply) {
          toggleState(userId, state);
        })
        .receive("error", (reason) => {
          //console.log("join failed", reason)
          toggleState(userId, !!state);
        })
        .receive("ignore", () => {
          //console.log("auth error")
          toggleState(userId, !!state);
        })
        .receive("timeout", () => {
          //console.log("connection interruption")
          toggleState(userId, !!state);
        });
    });

    channel.on("player:added", payload => {
      toggleState(payload.user_id, true);
    });

    channel.on("player:removed", payload => {
      toggleState(payload.user_id, false);
    });

  }
};

export default MatchCommitmentUpdates;
