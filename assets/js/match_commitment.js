let MatchCommitmentUpdates = {
  socket: null,
  userId: 0,
  channel: null,

  canInit: () => {
    return _.isNumber(MatchCommitmentUpdates.userId) && MatchCommitmentUpdates.userId > 0;
  },

  init: (socket, userId) => {
    MatchCommitmentUpdates.socket = socket;
    MatchCommitmentUpdates.userId = parseInt($('.js-match-commitments').data('user-id'));
    if (MatchCommitmentUpdates.canInit()) {
      MatchCommitmentUpdates.connectAndJoin();
      MatchCommitmentUpdates.initUIEvents();
    }
  },

  connectAndJoin: () => {
    MatchCommitmentUpdates.socket.connect();
    MatchCommitmentUpdates.channel = MatchCommitmentUpdates.socket.channel("match-commitments:" + MatchCommitmentUpdates.userId);

    MatchCommitmentUpdates.channel
      .join()
    //  .onError(e => console.log("something went wrong", e))
    //  .onClose(e => console.log("channel closed", e))
    //  .receive("ok", resp => { console.log("Joined successfully", resp); })
    //  .receive("error", resp => { console.log("Unable to join", resp); })
    ;
  },

  participate: (button, action) => {
    let matchId = button.closest('tr').data("match-id");

    MatchCommitmentUpdates.channel
      .push("participation:" + action, {user_id: MatchCommitmentUpdates.userId, match_id: matchId})
      .receive("ok", function(reply) {
        console.log(button.parent());
        button.parent().find('a').removeClass('active');
        button.addClass('active');
      })
      // .receive("error", (reason) => {
      // })
      // .receive("ignore", () => {
      // })
      // .receive("timeout", () => {
      // })
    ;
  },

  initUIEvents: () => {
    $('.js-match-participation a.js-participation-yes').on('click', function(e) {
      e.preventDefault();
      MatchCommitmentUpdates.participate($(this), 'yes');
      return false;
    });

    $('.js-match-participation a.js-participation-dont-no').on('click', function(e) {
      e.preventDefault();
      MatchCommitmentUpdates.participate($(this), 'dont-no');
      return false;
    });

    $('.js-match-participation a.js-participation-no').on('click', function(e) {
      e.preventDefault();
      MatchCommitmentUpdates.participate($(this), 'no');
      return false;
    });
  }
};

export default MatchCommitmentUpdates;
