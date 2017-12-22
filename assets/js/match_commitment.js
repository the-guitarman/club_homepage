let MatchCommitmentUpdates = {
  init(socket, userId) {
    if (_.isEmpty(userId)) {
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

    let participate = (button, action) => {
      let matchId = button.closest('tr').data("match-id");

      channel
        .push("participation:" + action, {user_id: userId, match_id: matchId})
        .receive("ok", function(reply) {
          console.log(button.parent());
          button.parent().find('a').removeClass('active');
          button.addClass('active');
        })
        .receive("error", (reason) => {
        })
        .receive("ignore", () => {
        })
        .receive("timeout", () => {
        });
    };

    $('.js-match-participation a.js-participation-yes').on('click', function(e) {
      e.preventDefault();
      participate($(this), 'yes');
      return false;
    });

    $('.js-match-participation a.js-participation-dont-no').on('click', function(e) {
      e.preventDefault();
      participate($(this), 'dont-no');
      return false;
    });

    $('.js-match-participation a.js-participation-no').on('click', function(e) {
      e.preventDefault();
      participate($(this), 'no');
      return false;
    });

  }
};

export default MatchCommitmentUpdates;
