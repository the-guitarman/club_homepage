let TeamChatBadge = {
  badgeSelector: '.js-new-team-chat-messages-badge', 
  socket: null,
  teamId: 0,
  userId: 0,
  channel: null,

  showNewMessagesBadge: (response) => {
    var unreadTeamChatMessagesNumber = response.unread_team_chat_messages_number;
    if (_.isNumber(unreadTeamChatMessagesNumber) && unreadTeamChatMessagesNumber > 0) {
      $(TeamChatBadge.badgeSelector).removeClass('hidden').html(unreadTeamChatMessagesNumber);
    } else {
      TeamChatBadge.hideNewMessagesBadge();
    }
  },

  hideNewMessagesBadge: () => {
    $(TeamChatBadge.badgeSelector).addClass('hidden').html('0');
  },

  connectAndJoin: () => {
    TeamChatBadge.socket.connect();
    TeamChatBadge.channel = TeamChatBadge.socket.channel("team-chat-badges:" + TeamChatBadge.teamId);
    TeamChatBadge.channel.onError(e => console.log("something went wrong", e));
    TeamChatBadge.channel.onClose(e => console.log("channel closed", e));

    TeamChatBadge.channel
      .join()
      .receive("ok", (response) => {
        TeamChatBadge.showNewMessagesBadge(response);
      })
      // .receive("error", (reason) => {
      //   console.log("join failed", reason);
      // })
      // .receive("ignore", () => {
      //   console.log("auth error");
      // })
      // .receive("timeout", () => {
      //   console.log("connection interruption");
      // })
    ;
  },

  initChannelEvents: () => {
    TeamChatBadge.channel.on("message:added", (payload) => {
      if (TeamChatBadge.userId != payload.current_user_id) {
        TeamChatBadge.showNewMessagesBadge(payload);
      }
    });
  },

  canInit: () => {
    return _.isNumber(TeamChatBadge.teamId) && TeamChatBadge.teamId > 0 &&
           _.isNumber(TeamChatBadge.userId) && TeamChatBadge.userId > 0;
  },

  init: (socket) => {
    TeamChatBadge.socket = socket;
    TeamChatBadge.teamId = parseInt($('.js-team-page').data('team-id'));
    TeamChatBadge.userId = parseInt($('body').data('current-user-id'));

    if (TeamChatBadge.canInit()) {
      TeamChatBadge.connectAndJoin();
      TeamChatBadge.initChannelEvents();
    }
  }
};

export default TeamChatBadge;
