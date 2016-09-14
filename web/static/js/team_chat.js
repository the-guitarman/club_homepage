let TeamChat = {
  init(socket, messageInput, teamId, userId) {
    if (messageInput.length === 0) {
      return
    }

    let messageList = $('#message-list');

    let createTime = (at) => {
      return at.hour + ':' + at.minute + ':' + at.second;
    }

    let createDate = (at) => {
      return moment(at.year + '-' + at.month + '-' + at.day).format('YYYY-MM-DD');
    }

    let createDateEl = (date) => {
      return `<div class="date text-center"><span>${moment(date).format('DD.MM.YYYY')}</span></div>`;
    }

    let createChatMessage = (payload) => {
      console.log(payload);
      var ownMessage = payload.user_id === parseInt(userId) ? ' own-message' : '';
      return `<div class="message${ownMessage}" data-id="${payload.id}" data-date="${createDate(payload.at)}"><div class="user-name">${payload.user_name || 'Anonymous'}:</div><div>${payload.message}</div><div class="time text-right">${createTime(payload.at)}</div></div>`;
    }

    let olderChatMessagesButtonHandler = (olderChatMessagesAvailable) => {
      var button = $('.js-show-more-chat-messages');
      if (olderChatMessagesAvailable === true) {
        button.removeProp('disabled').removeAttr('disabled');
      } else {
        button.prop('disabled', 'disabled').attr('disabled', 'disabled');
      }
    }

    let addDates = () => {
      messageList.find('.date').remove();
      var currentDate = null;
      $.each(messageList.find('.message'), function(index, messageEl){
        messageEl = $(messageEl);
        var date = messageEl.data('date');
        if (currentDate != date) {
          currentDate = date;
          messageEl.before(createDateEl(date));
        }
      });
    }

    socket.onOpen( ev => console.log("OPEN", ev) )
    socket.onError( ev => console.log("ERROR", ev) )
    socket.onClose( e => console.log("CLOSE", e))

    socket.connect()
    let teamIdChannel = socket.channel("team-chats:" + teamId)
    teamIdChannel.onError(e => console.log("something went wrong", e))
    teamIdChannel.onClose(e => console.log("channel closed", e))

    teamIdChannel.on("message:added", (payload) => {
      messageList.append(createChatMessage(payload));
      addDates();
      messageList.prop({scrollTop: messageList.prop("scrollHeight")});
    })
    teamIdChannel.on("message:show-older", (payload) => {
      $.each(payload.chat_messages, function(index, chatMessage){
        messageList.prepend(createChatMessage(chatMessage));
      });
      addDates();
      olderChatMessagesButtonHandler(payload.older_chat_messages_available);
    })

    teamIdChannel.join()
      .receive("ok", (response) => {
        messageList.html();
        $.each(response.chat_messages, function(index, chatMessage){
          messageList.append(createChatMessage(chatMessage));
        });
        addDates();
        olderChatMessagesButtonHandler(response.older_chat_messages_available);
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
        messageInput.focus();
      }
    });

    $('.js-show-more-chat-messages').on('click', event => {
      var oldestDisplayedChatMessageId = messageList.find('.message').first().data('id');
      teamIdChannel.push('message:show-older', {id_lower_than: oldestDisplayedChatMessageId});
    });
  }
}

export default TeamChat
