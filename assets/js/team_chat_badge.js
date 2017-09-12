let TeamChatBadge = {
  init(socket, teamId, userId) {
    if (_.isEmpty(teamId) || _.isEmpty(userId)) {
      return
    }

    let showNewMessagesBadge = (response) => {
      var unreadTeamChatMessagesNumber = response.unread_team_chat_messages_number;
      if (_.isNumber(unreadTeamChatMessagesNumber) && unreadTeamChatMessagesNumber > 0) {
        $('.js-new-team-chat-messages-badge').removeClass('hidden').html(unreadTeamChatMessagesNumber);
      } else {
        hideNewMessagesBadge();
      }
    }

    let hideNewMessagesBadge = () => {
      $('.js-new-team-chat-messages-badge').addClass('hidden').html('0');
    }

    socket.connect()
    let teamIdChannel = socket.channel("team-chat-badges:" + teamId)
    teamIdChannel.onError(e => console.log("something went wrong", e))
    teamIdChannel.onClose(e => console.log("channel closed", e))

    teamIdChannel.on("message:added", (payload) => {
      if (userId != payload.current_user_id) {
        showNewMessagesBadge(payload);
      }
    })

    teamIdChannel.join()
      .receive("ok", (response) => {
        showNewMessagesBadge(response);
      })
      .receive("error", (reason) => {
        console.log("join failed", reason)
      })
      .receive("ignore", () => {
        console.log("auth error")
      })
      .receive("timeout", () => {
        console.log("connection interruption")
      })
  }
}

export default TeamChatBadge
