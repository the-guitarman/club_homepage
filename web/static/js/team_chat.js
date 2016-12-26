let TeamChat = {
  init(socket, messageInput, teamId, userId) {
    if (messageInput.length === 0) {
      return
    }

    let messageList = $('#message-list');

    let createTime = (at) => {
      return moment(at).format('HH:mm:ss');
    }

    let createDate = (at) => {
      return moment(at).format('YYYY-MM-DD');
    }

    let createNewMessagesEl = () => {
      return `<div class="js-new-messages-hint css-new-messages-hint text-center"><div>Neue Nachrichten</div></div>`;
    }

    let createDateEl = (date) => {
      var format = messageList.data('date-format');
      return `<div class="date text-center"><span>${moment(date).format(format)}</span></div>`;
    }

    let createChatMessage = (payload) => {
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

    let addNewMessagesHint = (response) => {
      $('.js-new-messages-hint').remove();
      var last_read_team_chat_message_id = response.last_read_team_chat_message_id;
      if (_.isNumber(last_read_team_chat_message_id)) {
        $.each(messageList.find('.message'), function(index, messageEl){
          messageEl = $(messageEl);
          var id = messageEl.data('id');
          if (id == last_read_team_chat_message_id) {
            messageEl.after(createNewMessagesEl());
          }
        });
      }
    }

    let showNewMessagesBadge = (response) => {
      var unreadTeamChatMessagesNumber = response.unread_team_chat_messages_number;
      if (_.isNumber(unreadTeamChatMessagesNumber)) {
        $('.js-new-team-chat-messages-badge').removeClass('hidden').html(unreadTeamChatMessagesNumber);
      } else {
        hiddenNewMessagesBadge();
      }
    }

    let hiddenNewMessagesBadge = () => {
      $('.js-new-team-chat-messages-badge').addClass('hidden').html('0');
    }

    let scrollMessagesList = (response) => {
      var divScrollTop = 0;
      var messagesList = $("#message-list");
      var lastReadTeamChatMessageId = response.last_read_team_chat_message_id;
      var element = [];
      var newMessagesHint = messagesList.find('.js-new-messages-hint:last');
      if (newMessagesHint.length > 0) {
        element = newMessagesHint.last();
        var lastMessage = messagesList.find('.message:last');
        if (lastMessage.offset().top - element.offset().top < messagesList.outerHeight()) {
          element = lastMessage;
        }

      } else if (_.isNumber(lastReadTeamChatMessageId)) {
        element = messagesList.find('.message[data-id=' + lastReadTeamChatMessageId + ']');
      } else {
        element = messagesList.find('.message:last');
      }
      if (element.length > 0) {
        divScrollTop = element.offset().top - messagesList.offset().top;
      } else {
        divScrollTop = messagesList.outerHeight();
      }
      messagesList.animate({scrollTop: divScrollTop});
    }

    socket.onOpen( ev => console.log("OPEN", ev) )
    socket.onError( ev => console.log("ERROR", ev) )
    socket.onClose( e => console.log("CLOSE", e))

    socket.connect()
    let teamIdChannel = socket.channel("team-chats:" + teamId)
    teamIdChannel.onError(e => console.log("something went wrong", e))
    teamIdChannel.onClose(e => console.log("channel closed", e))

    teamIdChannel.on("message:added", (payload) => {
      messageList.append(createChatMessage(payload.chat_message));
      addDates();
      if (userId != payload.current_user_id) {
        addNewMessagesHint(payload);
        showNewMessagesBadge(payload);
      }
      //scrollMessagesList(payload);
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
        addNewMessagesHint(response);
        showNewMessagesBadge(payload);
        olderChatMessagesButtonHandler(response.older_chat_messages_available);
        scrollMessagesList(response);
        $('.js-new-team-chat-messages-badge').addClass('hidden').html('0');
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

    $(document).on( 'scroll', messageList, function(){
      hiddenNewMessagesBadge();
    });
  }
}

export default TeamChat
