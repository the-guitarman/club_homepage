let TeamChat = {
  init(socket, messageInput, teamId, userName) {
    if (messageInput.length === 0) {
      return
    }

    let appendChatMessage = (payload) => {
      let list = $('#message-list');
      list.append(`<b>${payload.user_name || 'Anonymous'}:</b> ${payload.message}<br>`);
      list.prop({scrollTop: list.prop("scrollHeight")});
    }

    socket.onOpen( ev => console.log("OPEN", ev) )
    socket.onError( ev => console.log("ERROR", ev) )
    socket.onClose( e => console.log("CLOSE", e))

    socket.connect()
    let teamIdChannel = socket.channel("team-chats:" + teamId)
    teamIdChannel.onError(e => console.log("something went wrong", e))
    teamIdChannel.onClose(e => console.log("channel closed", e))

    teamIdChannel
      .on("message:added", (payload) => {
        console.log("message added", payload)
        appendChatMessage(payload)
      })

    teamIdChannel.join()
      .receive("ok", (response) => {
        console.log("after join", response.chat_messages)
        $.each(response.chat_messages, function(index, chatMessage){
          appendChatMessage(chatMessage)
        })
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

    $('.glyphicon.glyphicon-send').parent().on('click', event => {
      let value = messageInput.val().trim();
      if (value.length > 0) {
        teamIdChannel.push('message:add', {message: value});
        messageInput.val('');
      }
    });
  }
}

export default TeamChat
